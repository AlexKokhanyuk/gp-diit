package edu.diploma.deadlocklab.delete;

import java.time.Duration;
import java.util.List;

public class DeleteResult {
    private final long subjectId;
    private final boolean success;
    private final String failedStep;
    private final String error;
    private final Duration duration;
    private final List<String> executedSteps;

    public DeleteResult(long subjectId, boolean success, String failedStep, String error,
                        Duration duration, List<String> executedSteps) {
        this.subjectId = subjectId;
        this.success = success;
        this.failedStep = failedStep;
        this.error = error;
        this.duration = duration;
        this.executedSteps = executedSteps;
    }

    public long getSubjectId() { return subjectId; }
    public boolean isSuccess() { return success; }
    public String getFailedStep() { return failedStep; }
    public String getError() { return error; }
    public Duration getDuration() { return duration; }
    public List<String> getExecutedSteps() { return executedSteps; }
}












