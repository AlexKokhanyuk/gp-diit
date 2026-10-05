package edu.diploma.deadlocklab.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "deadlock-lab.delete")
public class DeleteLabProperties {
    private boolean useSubjectDeleteLock;
    private long defaultPauseMs;
    public boolean isUseSubjectDeleteLock() { return useSubjectDeleteLock; }
    public void setUseSubjectDeleteLock(boolean useSubjectDeleteLock) { this.useSubjectDeleteLock = useSubjectDeleteLock; }
    public long getDefaultPauseMs() { return defaultPauseMs; }
    public void setDefaultPauseMs(long defaultPauseMs) { this.defaultPauseMs = defaultPauseMs; }
}












