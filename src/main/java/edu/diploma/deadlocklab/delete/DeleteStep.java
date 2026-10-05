package edu.diploma.deadlocklab.delete;

public class DeleteStep {
    private final String name;
    private final String sql;

    public DeleteStep(String name, String sql) {
        this.name = name;
        this.sql = sql;
    }

    public String getName() { return name; }
    public String getSql() { return sql; }
}













