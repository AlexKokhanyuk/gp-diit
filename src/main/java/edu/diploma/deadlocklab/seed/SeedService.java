package edu.diploma.deadlocklab.seed;

import edu.diploma.deadlocklab.delete.SubjectDeleteService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
public class SeedService {
    private static final List<String> CLEANUP_ORDER = Arrays.asList(
            "regulatory_tax_rows", "regulatory_tax_documents", "regulatory_payment_rows", "regulatory_payment_documents",
            "regulatory_sale_rows", "regulatory_sale_documents", "subject_status_events", "onboarding_attachments",
            "acls", "hardware_tokens", "key_events", "key_profiles", "access_keys", "mobile_links", "permission_events",
            "user_login_attempts", "key_requests", "user_ledgers", "user_accounts", "plastic_limits",
            "payment_plastics", "plastic_snapshots", "plastic_operations", "plastic_ledgers", "primary_ledgers", "ledger_operations",
            "ledger_snapshots", "ledger_accounts", "loan_schedules", "loan_debt_snapshots", "loan_operations", "loan_rate_events",
            "loan_segments", "loan_contracts", "savings_documents", "document_events", "document_recipients",
            "inbox_messages", "payroll_batches", "payroll_slips", "savings_open_requests", "card_open_requests",
            "payment_rule_create_requests", "payment_rule_stop_requests", "transfer_requests",
            "currency_payment_requests", "delivery_rejects", "card_funding_deliveries", "payment_rules",
            "savings_operations", "savings_rate_events", "savings_ledgers", "savings_contracts", "agent_cards", "partner_agents",
            "site_operations", "site_terminals", "merchant_sites", "subject_operation_links", "network_rules", "admin_subject_links",
            "document_watchers", "session_windows", "org_positions", "budget_items", "payment_recipients", "approved_recipients",
            "beneficiary_profiles", "message_links", "subject_properties", "corporate_recipients", "mobile_recipients", "trusted_payment_caps",
            "currency_agents", "subjects");

    private final JdbcTemplate jdbc;

    public SeedService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Transactional
    public SeedResult seed(int subjects, int fanout, boolean reset) {
        if (reset) resetData();
        List<Long> subjectIds = new ArrayList<>();
        long base = nextSubjectBase();
        for (int i = 0; i < subjects; i++) {
            long subjectId = base + i + 1;
            subjectIds.add(subjectId);
            insertSubject(subjectId, Math.max(1, fanout));
        }
        return new SeedResult(subjectIds, subjects, fanout);
    }

    private long nextSubjectBase() {
        Number value = jdbc.queryForObject("SELECT COALESCE(MAX(subject_id), 0) FROM subjects", Number.class);
        return value == null ? 0 : value.longValue();
    }

    private void resetData() {
        for (String table : CLEANUP_ORDER) jdbc.update("DELETE FROM " + table);
    }

    private void insertSubject(long subjectId, int fanout) {
        jdbc.update("INSERT INTO subjects(subject_id, subject_label, lifecycle_state) VALUES (?, ?, 0)", subjectId, "subject-" + subjectId);
        for (String table : Arrays.asList("subject_operation_links", "network_rules", "admin_subject_links", "document_watchers", "session_windows",
                "org_positions", "budget_items", "payment_recipients", "approved_recipients", "beneficiary_profiles", "message_links",
                "subject_properties", "corporate_recipients", "mobile_recipients", "trusted_payment_caps", "currency_agents",
                "onboarding_attachments", "subject_status_events", "payment_rules")) {
            insertIdSubject(table, nextId(subjectId, table.hashCode(), 0), subjectId);
        }
        for (int n = 1; n <= fanout; n++) insertFanout(subjectId, n);
    }

    private void insertFanout(long subjectId, int n) {
        long partner_agentsId = nextId(subjectId, 30, n);
        long employeeId = nextId(subjectId, 31, n);
        long keyId = nextId(subjectId, 32, n);
        long merchant_sitesId = nextId(subjectId, 33, n);
        long accountId = nextId(subjectId, 34, n);
        long cardId = nextId(subjectId, 35, n);
        long depositId = nextId(subjectId, 36, n);
        long depositAccountId = nextId(subjectId, 37, n);
        long creditId = nextId(subjectId, 38, n);

        jdbc.update("INSERT INTO partner_agents(id, subject_id) VALUES (?, ?)", partner_agentsId, subjectId);
        jdbc.update("INSERT INTO agent_cards(id, agent_id) VALUES (?, ?)", nextId(subjectId, 1, n), partner_agentsId);
        jdbc.update("INSERT INTO user_accounts(id, subject_id) VALUES (?, ?)", employeeId, subjectId);
        jdbc.update("INSERT INTO access_keys(key_id, subject_id, user_id) VALUES (?, ?, ?)", keyId, subjectId, employeeId);
        jdbc.update("INSERT INTO key_profiles(id, key_id) VALUES (?, ?)", nextId(subjectId, 2, n), keyId);
        jdbc.update("INSERT INTO key_events(id, key_id) VALUES (?, ?)", nextId(subjectId, 3, n), keyId);
        jdbc.update("INSERT INTO hardware_tokens(id, key_id) VALUES (?, ?)", nextId(subjectId, 4, n), keyId);
        jdbc.update("INSERT INTO mobile_links(id, subject_id, user_id) VALUES (?, ?, ?)", nextId(subjectId, 5, n), subjectId, employeeId);
        jdbc.update("INSERT INTO permission_events(id, user_id) VALUES (?, ?)", nextId(subjectId, 6, n), employeeId);
        jdbc.update("INSERT INTO user_login_attempts(id, user_id) VALUES (?, ?)", nextId(subjectId, 7, n), employeeId);
        jdbc.update("INSERT INTO key_requests(id, subject_id, user_id) VALUES (?, ?, ?)", nextId(subjectId, 8, n), subjectId, employeeId);
        jdbc.update("INSERT INTO acls(id, principal_type, principal_id) VALUES (?, 3, ?)", nextId(subjectId, 9, n), employeeId);

        jdbc.update("INSERT INTO merchant_sites(site_id, subject_id) VALUES (?, ?)", merchant_sitesId, subjectId);
        jdbc.update("INSERT INTO site_operations(id, site_id) VALUES (?, ?)", nextId(subjectId, 10, n), merchant_sitesId);
        jdbc.update("INSERT INTO site_terminals(id, site_id) VALUES (?, ?)", nextId(subjectId, 11, n), merchant_sitesId);

        jdbc.update("INSERT INTO savings_contracts(savings_id, subject_id) VALUES (?, ?)", depositId, subjectId);
        jdbc.update("INSERT INTO savings_ledgers(ledger_id, savings_id) VALUES (?, ?)", depositAccountId, depositId);
        jdbc.update("INSERT INTO savings_operations(id, ledger_id) VALUES (?, ?)", nextId(subjectId, 12, n), depositAccountId);
        jdbc.update("INSERT INTO savings_rate_events(id, ledger_id) VALUES (?, ?)", nextId(subjectId, 13, n), depositAccountId);

        jdbc.update("INSERT INTO loan_contracts(id, subject_id) VALUES (?, ?)", creditId, subjectId);
        for (String table : Arrays.asList("loan_schedules", "loan_debt_snapshots", "loan_operations", "loan_rate_events")) {
            jdbc.update("INSERT INTO " + table + "(id, loan_id) VALUES (?, ?)", nextId(subjectId, table.hashCode(), n), creditId);
        }
        jdbc.update("INSERT INTO loan_segments(id, subject_id, loan_id, loan_external_ref) VALUES (?, ?, ?, ?)", nextId(subjectId, 18, n), subjectId, creditId, "dog-" + creditId);

        jdbc.update("INSERT INTO ledger_accounts(id, subject_id) VALUES (?, ?)", accountId, subjectId);
        for (String table : Arrays.asList("primary_ledgers", "ledger_operations", "ledger_snapshots", "plastic_snapshots", "plastic_operations", "plastic_ledgers")) {
            jdbc.update("INSERT INTO " + table + "(id, ledger_id) VALUES (?, ?)", nextId(subjectId, table.hashCode(), n), accountId);
        }
        jdbc.update("INSERT INTO user_ledgers(id, ledger_id, user_id, external_ref) VALUES (?, ?, ?, ?)", nextId(subjectId, 22, n), accountId, employeeId, "e2-" + n);
        jdbc.update("INSERT INTO payment_plastics(plastic_id, ledger_id) VALUES (?, ?)", cardId, accountId);
        jdbc.update("INSERT INTO plastic_limits(id, ledger_id, plastic_id) VALUES (?, ?, ?)", nextId(subjectId, 23, n), accountId, cardId);

        insertDocuments(subjectId, n);
        insertRegisteredDocuments(subjectId, n);
    }

    private void insertDocuments(long subjectId, int n) {
        int salt = 100;
        for (String table : SubjectDeleteService.DOCUMENT_TABLES) {
            long docId = nextId(subjectId, salt++, n);
            jdbc.update("INSERT INTO " + table + "(document_id, subject_id) VALUES (?, ?)", docId, subjectId);
            jdbc.update("INSERT INTO document_events(id, document_id) VALUES (?, ?)", nextId(subjectId, salt++, n), docId);
            jdbc.update("INSERT INTO document_recipients(id, document_id, recipient_subject_id, recipient_kind) VALUES (?, ?, ?, 0)", nextId(subjectId, salt++, n), docId, subjectId);
            if ("savings_open_requests".equals(table)) jdbc.update("INSERT INTO savings_documents(id, document_id) VALUES (?, ?)", nextId(subjectId, salt++, n), docId);
        }
    }

    private void insertRegisteredDocuments(long subjectId, int n) {
        insertRegisteredDocumentPair("regulatory_sale_rows", "regulatory_sale_documents", subjectId, n);
        insertRegisteredDocumentPair("regulatory_payment_rows", "regulatory_payment_documents", subjectId, n);
        insertRegisteredDocumentPair("regulatory_tax_rows", "regulatory_tax_documents", subjectId, n);
    }

    private void insertRegisteredDocumentPair(String rowTable, String documentTable, long subjectId, int n) {
        long docId = nextId(subjectId, rowTable.hashCode(), n);
        jdbc.update("INSERT INTO " + documentTable + "(document_id, subject_id) VALUES (?, ?)", docId, subjectId);
        jdbc.update("INSERT INTO " + rowTable + "(id, document_id) VALUES (?, ?)", nextId(subjectId, rowTable.hashCode() + 1, n), docId);
    }

    private void insertIdSubject(String table, long id, long subjectId) {
        jdbc.update("INSERT INTO " + table + "(id, subject_id) VALUES (?, ?)", id, subjectId);
    }

    private long nextId(long subjectId, int salt, int n) {
        long compactSalt = Math.abs((long) salt % 1_000L);
        return subjectId * 1_000_000L + compactSalt * 1_000L + n;
    }

    public static class SeedResult {
        private final List<Long> subjectIds;
        private final int subjects;
        private final int fanout;

        public SeedResult(List<Long> subjectIds, int subjects, int fanout) {
            this.subjectIds = subjectIds;
            this.subjects = subjects;
            this.fanout = fanout;
        }

        public List<Long> getSubjectIds() { return subjectIds; }
        public int getSubjects() { return subjects; }
        public int getFanout() { return fanout; }
    }
}















