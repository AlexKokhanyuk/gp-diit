package edu.diploma.deadlocklab.delete;

import edu.diploma.deadlocklab.config.DeleteLabProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
public class SubjectDeleteService {
    private static final Logger LOG = LoggerFactory.getLogger(SubjectDeleteService.class);
    private static final Object SUBJECT_DELETE_LOCK = new Object();

    public static final List<String> DOCUMENT_TABLES = Arrays.asList(
            "inbox_messages", "payroll_batches", "payroll_slips", "savings_open_requests", "card_open_requests",
            "payment_rule_create_requests", "payment_rule_stop_requests", "transfer_requests",
            "currency_payment_requests", "delivery_rejects", "card_funding_deliveries");

    private static final List<String> FINAL_SUBJECT_TABLES = Arrays.asList(
            "merchant_sites", "subject_operation_links", "network_rules", "admin_subject_links", "document_watchers", "session_windows",
            "org_positions", "budget_items", "payment_recipients", "approved_recipients", "beneficiary_profiles", "message_links",
            "subject_properties", "corporate_recipients", "mobile_recipients", "trusted_payment_caps", "currency_agents", "subjects");

    private final JdbcTemplate jdbc;
    private final TransactionTemplate transactionTemplate;
    private final DeleteLabProperties properties;

    public SubjectDeleteService(JdbcTemplate jdbc, PlatformTransactionManager transactionManager, DeleteLabProperties properties) {
        this.jdbc = jdbc;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.properties = properties;
    }

    public DeleteResult deleteSubject(long subjectId, DeleteMode mode, String pauseAfterStep, Long pauseMs, Boolean forceLock) {
        boolean lock = forceLock != null ? forceLock : properties.isUseSubjectDeleteLock();
        if (lock) {
            synchronized (SUBJECT_DELETE_LOCK) {
                return deleteSubjectInTransaction(subjectId, mode, pauseAfterStep, pauseMs);
            }
        }
        return deleteSubjectInTransaction(subjectId, mode, pauseAfterStep, pauseMs);
    }

    private DeleteResult deleteSubjectInTransaction(long subjectId, DeleteMode mode, String pauseAfterStep, Long pauseMs) {
        Instant started = Instant.now();
        List<String> steps = new ArrayList<>();
        try {
            return transactionTemplate.execute(status -> {
                deleteSubjectData(subjectId, mode, pauseAfterStep, pauseMs, steps);
                return new DeleteResult(subjectId, true, null, null, Duration.between(started, Instant.now()), steps);
            });
        } catch (RuntimeException ex) {
            String failedStep = steps.isEmpty() ? "before-delete" : steps.get(steps.size() - 1);
            return new DeleteResult(subjectId, false, failedStep, rootMessage(ex), Duration.between(started, Instant.now()), steps);
        }
    }

    private void deleteSubjectData(long subjectId, DeleteMode mode, String pauseAfterStep, Long pauseMs, List<String> steps) {
        deleteInitialChildren(subjectId, pauseAfterStep, pauseMs, steps);
        deleteSavings(subjectId, pauseAfterStep, pauseMs, steps);
        deleteDocumentRecipients(subjectId, pauseAfterStep, pauseMs, steps);
        deleteRegularPayments(subjectId, pauseAfterStep, pauseMs, steps);
        deleteDocuments(subjectId, pauseAfterStep, pauseMs, steps);
        deleteLoans(subjectId, pauseAfterStep, pauseMs, steps);
        deleteLedgerAccounts(subjectId, mode, pauseAfterStep, pauseMs, steps);
        deleteSpecialData(subjectId, pauseAfterStep, pauseMs, steps);
        deleteRegisteredDocumentTables(subjectId, pauseAfterStep, pauseMs, steps);
        execute("onboarding_attachments", "DELETE FROM onboarding_attachments WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("subject_status_events", "DELETE FROM subject_status_events WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        for (String table : FINAL_SUBJECT_TABLES) {
            execute("subjectTable:" + table, "DELETE FROM " + table + " WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        }
    }

    private void deleteInitialChildren(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("key_profiles", "DELETE FROM key_profiles WHERE key_id IN (SELECT key_id FROM access_keys WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("agent_cards", "DELETE FROM agent_cards WHERE agent_id IN (SELECT id FROM partner_agents WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("partner_agents", "DELETE FROM partner_agents WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("site_operations", "DELETE FROM site_operations WHERE site_id IN (SELECT site_id FROM merchant_sites WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("site_terminals", "DELETE FROM site_terminals WHERE site_id IN (SELECT site_id FROM merchant_sites WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteSavings(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        String filter = " IN (SELECT ledger_id FROM savings_ledgers WHERE savings_id IN (SELECT savings_id FROM savings_contracts WHERE subject_id=?))";
        execute("savings_operations", "DELETE FROM savings_operations WHERE ledger_id" + filter, subjectId, pauseAfterStep, pauseMs, steps);
        execute("savings_rate_events", "DELETE FROM savings_rate_events WHERE ledger_id" + filter, subjectId, pauseAfterStep, pauseMs, steps);
        execute("savings_ledgers", "DELETE FROM savings_ledgers WHERE savings_id IN (SELECT savings_id FROM savings_contracts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("savings_contracts", "DELETE FROM savings_contracts WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteDocumentRecipients(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("document_recipients:inbox_messages", "DELETE FROM document_recipients WHERE document_id IN (SELECT document_id FROM inbox_messages WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("inbox_messages:recipient", "DELETE FROM inbox_messages WHERE document_id IN (SELECT document_id FROM document_recipients WHERE recipient_subject_id=? AND recipient_kind=0)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("document_recipients:recipient", "DELETE FROM document_recipients WHERE recipient_subject_id=? AND recipient_kind=0", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteRegularPayments(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("payment_rules", "DELETE FROM payment_rules WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteDocuments(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("savings_documents", "DELETE FROM savings_documents WHERE document_id IN (SELECT document_id FROM savings_open_requests WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        for (String table : DOCUMENT_TABLES) {
            execute("document_events:" + table, "DELETE FROM document_events WHERE document_id IN (SELECT document_id FROM " + table + " WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
            execute("documents:" + table, "DELETE FROM " + table + " WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        }
    }

    private void deleteLoans(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        for (String table : Arrays.asList("loan_schedules", "loan_debt_snapshots", "loan_operations", "loan_rate_events")) {
            execute("deleteLoans:" + table, "DELETE FROM " + table + " WHERE loan_id IN (SELECT id FROM loan_contracts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        }
        execute("deleteLoans:loan_segments", "DELETE FROM loan_segments WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("deleteLoans:loan_contracts", "DELETE FROM loan_contracts WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteLedgerAccounts(long subjectId, DeleteMode mode, String pauseAfterStep, Long pauseMs, List<String> steps) {
        String accountFilter = mode == DeleteMode.LEGACY ? " IN (SELECT id FROM ledger_accounts WHERE subject_id=?)" : " IN (SELECT a.id FROM ledger_accounts a WHERE a.subject_id=?)";
        for (String table : Arrays.asList("primary_ledgers", "ledger_operations", "ledger_snapshots", "user_ledgers")) {
            execute("ledger_accounts:" + table, "DELETE FROM " + table + " WHERE ledger_id" + accountFilter, subjectId, pauseAfterStep, pauseMs, steps);
        }
        execute("ledger_accounts:plastic_limits:cards", "DELETE FROM plastic_limits WHERE plastic_id IN (SELECT plastic_id FROM payment_plastics WHERE ledger_id" + accountFilter + ")", subjectId, pauseAfterStep, pauseMs, steps);
        execute("ledger_accounts:plastic_limits:ledger_accounts", "DELETE FROM plastic_limits WHERE ledger_id" + accountFilter, subjectId, pauseAfterStep, pauseMs, steps);
        for (String table : Arrays.asList("payment_plastics", "plastic_snapshots", "plastic_operations", "plastic_ledgers")) {
            execute("ledger_accounts:" + table, "DELETE FROM " + table + " WHERE ledger_id" + accountFilter, subjectId, pauseAfterStep, pauseMs, steps);
        }
        String deleteLedgerAccountsSql = mode == DeleteMode.LEGACY ? "DELETE FROM ledger_accounts WHERE id IN (SELECT id FROM ledger_accounts WHERE subject_id=?)" : "DELETE FROM ledger_accounts WHERE subject_id=?";
        execute("ledger_accounts:ledger_accounts", deleteLedgerAccountsSql, subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteSpecialData(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("hardware_tokens", "DELETE FROM hardware_tokens WHERE key_id IN (SELECT key_id FROM access_keys WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:permissions", "DELETE FROM acls WHERE principal_type=3 AND principal_id IN (SELECT id FROM user_accounts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:key_events", "DELETE FROM key_events WHERE key_id IN (SELECT key_id FROM access_keys WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:access_keys", "DELETE FROM access_keys WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:mobile_links", "DELETE FROM mobile_links WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:permission_events", "DELETE FROM permission_events WHERE user_id IN (SELECT id FROM user_accounts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:login_attempts", "DELETE FROM user_login_attempts WHERE user_id IN (SELECT id FROM user_accounts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:key_requests:subject", "DELETE FROM key_requests WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:user_ledgers", "DELETE FROM user_ledgers WHERE user_id IN (SELECT id FROM user_accounts WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("user_accounts:user_accounts", "DELETE FROM user_accounts WHERE subject_id=?", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteRegisteredDocumentTables(long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        deleteRegisteredDocumentPair("regulatory_sale_rows", "regulatory_sale_documents", subjectId, pauseAfterStep, pauseMs, steps);
        deleteRegisteredDocumentPair("regulatory_payment_rows", "regulatory_payment_documents", subjectId, pauseAfterStep, pauseMs, steps);
        deleteRegisteredDocumentPair("regulatory_tax_rows", "regulatory_tax_documents", subjectId, pauseAfterStep, pauseMs, steps);
    }

    private void deleteRegisteredDocumentPair(String rowTable, String documentTable, long subjectId,
                                              String pauseAfterStep, Long pauseMs, List<String> steps) {
        execute("regDocuments:" + rowTable, "DELETE FROM " + rowTable + " WHERE document_id IN " +
                "(SELECT document_id FROM " + documentTable + " WHERE subject_id=?)", subjectId, pauseAfterStep, pauseMs, steps);
        execute("regDocuments:" + documentTable, "DELETE FROM " + documentTable + " WHERE subject_id=?", subjectId,
                pauseAfterStep, pauseMs, steps);
    }

    private void execute(String step, String sql, long subjectId, String pauseAfterStep, Long pauseMs, List<String> steps) {
        steps.add(step);
        try {
            LOG.debug("Subject delete step. step={}, subjectId={}, sql={}", step, subjectId, sql);
            jdbc.update(sql, subjectId);
            pauseIfNeeded(step, pauseAfterStep, pauseMs);
        } catch (RuntimeException ex) {
            LOG.debug("Subject delete failed. step={}, subjectId={}, sql={}, error={}", step, subjectId, sql, rootMessage(ex));
            throw ex;
        }
    }

    private void pauseIfNeeded(String step, String pauseAfterStep, Long pauseMs) {
        if (pauseAfterStep == null || pauseAfterStep.trim().isEmpty() || !step.equals(pauseAfterStep)) return;
        long delay = pauseMs != null ? pauseMs : properties.getDefaultPauseMs();
        if (delay <= 0) return;
        try {
            Thread.sleep(delay);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(e);
        }
    }

    private String rootMessage(Throwable throwable) {
        Throwable root = throwable;
        while (root.getCause() != null) root = root.getCause();
        return root.getMessage();
    }
}
















