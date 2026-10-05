package edu.diploma.deadlocklab.web;

import edu.diploma.deadlocklab.delete.DeleteMode;
import edu.diploma.deadlocklab.delete.DeleteResult;
import edu.diploma.deadlocklab.delete.SubjectDeleteService;
import edu.diploma.deadlocklab.seed.SeedService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@RestController
@RequestMapping("/lab")
public class SubjectDeleteController {
    private static final List<String> STATS_TABLES = Arrays.asList(
            "subjects", "user_accounts", "access_keys", "key_events", "key_profiles", "key_requests",
            "ledger_accounts", "user_ledgers", "primary_ledgers", "ledger_operations", "ledger_snapshots",
            "payment_plastics", "plastic_limits", "plastic_snapshots", "plastic_operations", "plastic_ledgers",
            "loan_contracts", "loan_schedules", "loan_debt_snapshots", "loan_operations", "loan_rate_events", "loan_segments",
            "savings_contracts", "savings_ledgers", "savings_operations", "savings_rate_events",
            "document_events", "document_recipients", "inbox_messages", "payroll_batches", "payroll_slips",
            "savings_open_requests", "card_open_requests", "payment_rule_create_requests", "payment_rule_stop_requests",
            "transfer_requests", "currency_payment_requests", "delivery_rejects", "card_funding_deliveries", "savings_documents",
            "regulatory_sale_documents", "regulatory_sale_rows", "regulatory_payment_documents", "regulatory_payment_rows",
            "regulatory_tax_documents", "regulatory_tax_rows", "partner_agents", "agent_cards", "merchant_sites",
            "site_operations", "site_terminals", "payment_rules", "subject_operation_links", "network_rules",
            "admin_subject_links", "document_watchers", "session_windows", "org_positions", "budget_items",
            "payment_recipients", "approved_recipients", "beneficiary_profiles", "message_links", "subject_properties",
            "corporate_recipients", "mobile_recipients", "trusted_payment_caps", "currency_agents", "onboarding_attachments",
            "subject_status_events", "acls", "hardware_tokens", "mobile_links", "permission_events", "user_login_attempts");

    private final SubjectDeleteService subjectDeleteService;
    private final SeedService seedService;
    private final JdbcTemplate jdbc;
    private final Environment environment;
    private final DataSource dataSource;

    public SubjectDeleteController(SubjectDeleteService subjectDeleteService, SeedService seedService,
                                   JdbcTemplate jdbc, Environment environment, DataSource dataSource) {
        this.subjectDeleteService = subjectDeleteService;
        this.seedService = seedService;
        this.jdbc = jdbc;
        this.environment = environment;
        this.dataSource = dataSource;
    }

    @GetMapping("/environment")
    public Map<String, Object> environment() throws SQLException {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("activeProfiles", Arrays.asList(environment.getActiveProfiles()));
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData meta = connection.getMetaData();
            result.put("databaseProductName", meta.getDatabaseProductName());
            result.put("databaseProductVersion", meta.getDatabaseProductVersion());
            result.put("jdbcUrl", meta.getURL());
            result.put("userName", meta.getUserName());
        }
        return result;
    }
    @PostMapping("/seed")
    public SeedService.SeedResult seed(@RequestParam(defaultValue = "5") int subjects,
                                       @RequestParam(defaultValue = "3") int fanout,
                                       @RequestParam(defaultValue = "true") boolean reset) {
        return seedService.seed(subjects, fanout, reset);
    }

    @DeleteMapping("/subjects/{subjectId}")
    public ResponseEntity<DeleteResult> deleteSubject(@PathVariable long subjectId,
                                                     @RequestParam(defaultValue = "LEGACY") DeleteMode mode,
                                                     @RequestParam(required = false) String pauseAfterStep,
                                                     @RequestParam(required = false) Long pauseMs,
                                                     @RequestParam(required = false) Boolean lock) {
        DeleteResult result = subjectDeleteService.deleteSubject(subjectId, mode, pauseAfterStep, pauseMs, lock);
        return ResponseEntity.status(result.isSuccess() ? HttpStatus.OK : HttpStatus.INTERNAL_SERVER_ERROR).body(result);
    }

    @PostMapping("/delete-parallel")
    public List<DeleteResult> deleteParallel(@RequestBody ParallelDeleteRequest request) throws Exception {
        int threads = request.getThreads() == null ? request.getSubjectIds().size() : request.getThreads();
        ExecutorService executor = Executors.newFixedThreadPool(Math.max(1, threads));
        try {
            List<Callable<DeleteResult>> tasks = new ArrayList<Callable<DeleteResult>>();
            for (final Long subjectId : request.getSubjectIds()) {
                tasks.add(new Callable<DeleteResult>() {
                    @Override
                    public DeleteResult call() {
                        return subjectDeleteService.deleteSubject(
                                subjectId,
                                request.getMode() == null ? DeleteMode.LEGACY : request.getMode(),
                                request.getPauseAfterStep(),
                                request.getPauseMs(),
                                request.getLock());
                    }
                });
            }
            List<Future<DeleteResult>> futures = executor.invokeAll(tasks);
            List<DeleteResult> results = new ArrayList<DeleteResult>();
            for (Future<DeleteResult> future : futures) results.add(future.get());
            return results;
        } finally {
            executor.shutdownNow();
        }
    }

    @GetMapping("/relationships")
    public Map<String, Object> relationships() {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("subjectChildren", Arrays.asList("partner_agents", "user_accounts", "access_keys", "ledger_accounts", "loan_contracts",
                "savings_contracts", "merchant_sites", "documents", "trusted_payment_caps", "currency_agents"));
        result.put("hotspots", Arrays.asList("ledger_accounts self-subquery", "user_ledgers by user_id", "key_events by key_id",
                "loan_contracts", "final subjects delete"));
        result.put("documentTables", SubjectDeleteService.DOCUMENT_TABLES);
        return result;
    }

    @GetMapping("/table/{table}")
    public Map<String, Object> table(@PathVariable String table,
                                     @RequestParam(defaultValue = "50") int limit) {
        if (!STATS_TABLES.contains(table)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown table: " + table);
        }
        final int safeLimit = Math.max(1, Math.min(limit, 500));
        final List<String> columns = new ArrayList<String>();
        List<Map<String, Object>> rows = jdbc.query("SELECT * FROM " + table, ps -> ps.setMaxRows(safeLimit), rs -> {
            List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
            java.sql.ResultSetMetaData meta = rs.getMetaData();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                columns.add(meta.getColumnLabel(i));
            }
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<String, Object>();
                for (String column : columns) {
                    row.put(column, rs.getObject(column));
                }
                result.add(row);
            }
            return result;
        });

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("table", table);
        result.put("limit", safeLimit);
        result.put("columns", columns);
        result.put("rows", rows);
        result.put("rowCount", rows.size());
        return result;
    }
    @GetMapping("/stats")
    public Map<String, Object> stats() {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("time", Instant.now().toString());
        result.put("subjectCount", count("subjects"));
        result.put("firstSubjectId", scalar("SELECT MIN(subject_id) FROM subjects"));
        result.put("lastSubjectId", scalar("SELECT MAX(subject_id) FROM subjects"));
        result.put("subjectIds", jdbc.queryForList("SELECT subject_id FROM subjects ORDER BY subject_id", Long.class));

        List<Map<String, Object>> tables = new ArrayList<Map<String, Object>>();
        long totalRows = 0;
        for (String table : STATS_TABLES) {
            long rows = count(table);
            totalRows += rows;
            Map<String, Object> item = new LinkedHashMap<String, Object>();
            item.put("table", table);
            item.put("rows", rows);
            tables.add(item);
        }
        result.put("totalRows", totalRows);
        result.put("tables", tables);
        return result;
    }

    private long count(String table) {
        Number value = jdbc.queryForObject("SELECT COUNT(*) FROM " + table, Number.class);
        return value == null ? 0 : value.longValue();
    }

    private Object scalar(String sql) {
        return jdbc.queryForObject(sql, Object.class);
    }

    public static class ParallelDeleteRequest {
        private List<Long> subjectIds;
        private Integer threads;
        private DeleteMode mode;
        private String pauseAfterStep;
        private Long pauseMs;
        private Boolean lock;

        public List<Long> getSubjectIds() { return subjectIds; }
        public void setSubjectIds(List<Long> subjectIds) { this.subjectIds = subjectIds; }
        public Integer getThreads() { return threads; }
        public void setThreads(Integer threads) { this.threads = threads; }
        public DeleteMode getMode() { return mode; }
        public void setMode(DeleteMode mode) { this.mode = mode; }
        public String getPauseAfterStep() { return pauseAfterStep; }
        public void setPauseAfterStep(String pauseAfterStep) { this.pauseAfterStep = pauseAfterStep; }
        public Long getPauseMs() { return pauseMs; }
        public void setPauseMs(Long pauseMs) { this.pauseMs = pauseMs; }
        public Boolean getLock() { return lock; }
        public void setLock(Boolean lock) { this.lock = lock; }
    }
}


