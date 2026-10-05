package edu.diploma.deadlocklab.bootstrap;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DockerDatabaseBootstrap {
    public static void main(String[] args) throws Exception {
        String target = prop("docker.target", "mssql").toLowerCase();
        if ("mssql".equals(target) || "sqlserver".equals(target)) {
            bootstrapMssqlDatabase();
        } else if ("postgresql".equals(target) || "postgres".equals(target) || "pg".equals(target)) {
            waitForPostgresql();
        } else if ("oracle".equals(target)) {
            waitForOracle();
        } else {
            throw new IllegalArgumentException("Unknown docker.target: " + target);
        }
    }

    private static void bootstrapMssqlDatabase() throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = prop("docker.mssql.admin.url", "jdbc:sqlserver://localhost:14333;databaseName=master;encrypt=false;trustServerCertificate=true");
        String user = prop("docker.mssql.admin.user", "sa");
        String password = prop("docker.mssql.admin.password", "Your_strong_password_123");
        String database = prop("docker.mssql.database", "deadlock_lab");
        System.out.println("Docker MSSQL bootstrap: database=" + database + ", url=" + url);

        try (Connection connection = waitForConnection(url, user, password);
             Statement statement = connection.createStatement()) {
            connection.setAutoCommit(true);
            statement.execute("IF DB_ID(N'" + database.replace("'", "''") + "') IS NULL CREATE DATABASE [" + database.replace("]", "]]") + "]");
            try (ResultSet rs = statement.executeQuery("SELECT DB_ID(N'" + database.replace("'", "''") + "')")) {
                rs.next();
                if (rs.getObject(1) == null) throw new IllegalStateException("Database was not created: " + database);
            }
            System.out.println("Docker MSSQL database is ready: " + database);
        }
    }

    private static Connection waitForConnection(String url, String user, String password) throws Exception {
        int attempts = Integer.parseInt(prop("docker.wait.attempts", prop("docker.mssql.wait.attempts", "90")));
        long delayMs = Long.parseLong(prop("docker.wait.delay.ms", prop("docker.mssql.wait.delay.ms", "2000")));
        Exception last = null;
        for (int i = 1; i <= attempts; i++) {
            try {
                return DriverManager.getConnection(url, user, password);
            } catch (Exception ex) {
                last = ex;
                System.out.println("Database is not ready yet (attempt " + i + "/" + attempts + "): " + ex.getMessage());
                Thread.sleep(delayMs);
            }
        }
        throw last;
    }

    private static void waitForPostgresql() throws Exception {
        Class.forName("org.postgresql.Driver");
        String url = prop("docker.postgresql.url", "jdbc:postgresql://localhost:15432/deadlock_lab?options=-c%20TimeZone=UTC");
        String user = prop("docker.postgresql.user", "deadlock_lab");
        String password = prop("docker.postgresql.password", "deadlock_lab");
        System.out.println("Docker PostgreSQL wait: url=" + url);
        try (Connection ignored = waitForConnection(url, user, password)) {
            System.out.println("Docker PostgreSQL is ready");
        }
    }

    private static void waitForOracle() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        String url = prop("docker.oracle.url", "jdbc:oracle:thin:@localhost:1521/FREEPDB1");
        String user = prop("docker.oracle.user", "deadlock_lab");
        String password = prop("docker.oracle.password", "deadlock_lab");
        System.out.println("Docker Oracle wait: url=" + url);
        try (Connection connection = waitForConnection(url, user, password)) {
            repairFailedFlywayRows(connection);
            System.out.println("Docker Oracle is ready");
        }
    }

    private static void repairFailedFlywayRows(Connection connection) throws SQLException {
        if (!tableExists(connection, "FLYWAY_SCHEMA_HISTORY")) return;
        try (Statement statement = connection.createStatement()) {
            int deleted = statement.executeUpdate("DELETE FROM \"flyway_schema_history\" WHERE \"success\" = 0");
            if (deleted > 0) {
                System.out.println("Removed failed Flyway history rows: " + deleted);
            }
        }
    }

    private static boolean tableExists(Connection connection, String tableName) throws SQLException {
        try (Statement statement = connection.createStatement();
             ResultSet rs = statement.executeQuery("SELECT 1 FROM user_tables WHERE LOWER(table_name) = LOWER('" + tableName.replace("'", "''") + "')")) {
            return rs.next();
        }
    }

    private static String prop(String name, String defaultValue) {
        String value = System.getProperty(name);
        if (value != null && !value.trim().isEmpty()) return value.trim();
        String envName = name.toUpperCase().replace('.', '_').replace('-', '_');
        value = System.getenv(envName);
        if (value != null && !value.trim().isEmpty()) return value.trim();
        return defaultValue;
    }
}
