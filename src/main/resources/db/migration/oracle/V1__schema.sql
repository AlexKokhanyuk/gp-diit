CREATE TABLE subjects (subject_id NUMBER(19) NOT NULL PRIMARY KEY, subject_label VARCHAR2(255) NOT NULL, lifecycle_state NUMBER(10) DEFAULT 0 NOT NULL);
CREATE TABLE merchant_sites (site_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE site_operations (id NUMBER(19) NOT NULL PRIMARY KEY, site_id NUMBER(19) NOT NULL, FOREIGN KEY (site_id) REFERENCES merchant_sites(site_id));
CREATE TABLE site_terminals (id NUMBER(19) NOT NULL PRIMARY KEY, site_id NUMBER(19) NOT NULL, FOREIGN KEY (site_id) REFERENCES merchant_sites(site_id));
CREATE TABLE partner_agents (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE agent_cards (id NUMBER(19) NOT NULL PRIMARY KEY, agent_id NUMBER(19) NOT NULL, FOREIGN KEY (agent_id) REFERENCES partner_agents(id));
CREATE TABLE user_accounts (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE access_keys (key_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, user_id NUMBER(19), FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE key_profiles (id NUMBER(19) NOT NULL PRIMARY KEY, key_id NUMBER(19) NOT NULL, FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE key_events (id NUMBER(19) NOT NULL PRIMARY KEY, key_id NUMBER(19) NOT NULL, FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE hardware_tokens (id NUMBER(19) NOT NULL PRIMARY KEY, key_id NUMBER(19) NOT NULL, FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE mobile_links (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, user_id NUMBER(19), FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE permission_events (id NUMBER(19) NOT NULL PRIMARY KEY, user_id NUMBER(19) NOT NULL, FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE user_login_attempts (id NUMBER(19) NOT NULL PRIMARY KEY, user_id NUMBER(19) NOT NULL, FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE key_requests (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, user_id NUMBER(19), FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE acls (id NUMBER(19) NOT NULL PRIMARY KEY, principal_type INT NOT NULL, principal_id NUMBER(19) NOT NULL);
CREATE TABLE ledger_accounts (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE primary_ledgers (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE ledger_operations (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE ledger_snapshots (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE user_ledgers (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, user_id NUMBER(19) NOT NULL, external_ref VARCHAR2(64), FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id), FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE payment_plastics (plastic_id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_limits (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, plastic_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id), FOREIGN KEY (plastic_id) REFERENCES payment_plastics(plastic_id));
CREATE TABLE plastic_snapshots (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_operations (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_ledgers (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE savings_contracts (savings_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE savings_ledgers (ledger_id NUMBER(19) NOT NULL PRIMARY KEY, savings_id NUMBER(19) NOT NULL, FOREIGN KEY (savings_id) REFERENCES savings_contracts(savings_id));
CREATE TABLE savings_operations (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES savings_ledgers(ledger_id));
CREATE TABLE savings_rate_events (id NUMBER(19) NOT NULL PRIMARY KEY, ledger_id NUMBER(19) NOT NULL, FOREIGN KEY (ledger_id) REFERENCES savings_ledgers(ledger_id));
CREATE TABLE loan_contracts (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE loan_schedules (id NUMBER(19) NOT NULL PRIMARY KEY, loan_id NUMBER(19) NOT NULL, FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_debt_snapshots (id NUMBER(19) NOT NULL PRIMARY KEY, loan_id NUMBER(19) NOT NULL, FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_operations (id NUMBER(19) NOT NULL PRIMARY KEY, loan_id NUMBER(19) NOT NULL, FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_rate_events (id NUMBER(19) NOT NULL PRIMARY KEY, loan_id NUMBER(19) NOT NULL, FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_segments (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, loan_id NUMBER(19) NOT NULL, loan_external_ref VARCHAR2(64), FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE document_events (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL);
CREATE TABLE document_recipients (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL, recipient_subject_id NUMBER(19) NOT NULL, recipient_kind INT NOT NULL);
CREATE TABLE savings_documents (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL);
CREATE TABLE inbox_messages (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payroll_batches (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payroll_slips (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE savings_open_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE card_open_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rule_create_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rule_stop_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE transfer_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE currency_payment_requests (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE delivery_rejects (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE card_funding_deliveries (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rules (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_sale_documents (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_sale_rows (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL, FOREIGN KEY (document_id) REFERENCES regulatory_sale_documents(document_id));
CREATE TABLE regulatory_payment_documents (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_payment_rows (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL, FOREIGN KEY (document_id) REFERENCES regulatory_payment_documents(document_id));
CREATE TABLE regulatory_tax_documents (document_id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_tax_rows (id NUMBER(19) NOT NULL PRIMARY KEY, document_id NUMBER(19) NOT NULL, FOREIGN KEY (document_id) REFERENCES regulatory_tax_documents(document_id));
CREATE TABLE subject_operation_links (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE network_rules (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE admin_subject_links (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE document_watchers (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE session_windows (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE org_positions (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE budget_items (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_recipients (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE approved_recipients (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE beneficiary_profiles (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE message_links (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE subject_properties (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE corporate_recipients (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE mobile_recipients (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE trusted_payment_caps (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE currency_agents (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE onboarding_attachments (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE subject_status_events (id NUMBER(19) NOT NULL PRIMARY KEY, subject_id NUMBER(19) NOT NULL, FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));











