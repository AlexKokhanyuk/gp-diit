CREATE TABLE subjects (subject_id BIGINT NOT NULL PRIMARY KEY, subject_label VARCHAR(255) NOT NULL, lifecycle_state INT NOT NULL DEFAULT 0);
CREATE TABLE merchant_sites (site_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_merchant_sites_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE site_operations (id BIGINT NOT NULL PRIMARY KEY, site_id BIGINT NOT NULL, CONSTRAINT fk_site_ops_sites FOREIGN KEY (site_id) REFERENCES merchant_sites(site_id));
CREATE TABLE site_terminals (id BIGINT NOT NULL PRIMARY KEY, site_id BIGINT NOT NULL, CONSTRAINT fk_site_terminals_merchant_sites FOREIGN KEY (site_id) REFERENCES merchant_sites(site_id));
CREATE TABLE partner_agents (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_partner_agents_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE agent_cards (id BIGINT NOT NULL PRIMARY KEY, agent_id BIGINT NOT NULL, CONSTRAINT fk_agent_cards_partner_agents FOREIGN KEY (agent_id) REFERENCES partner_agents(id));
CREATE TABLE user_accounts (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_user_accounts_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE access_keys (key_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, user_id BIGINT, CONSTRAINT fk_access_keys_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), CONSTRAINT fk_access_keys_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE key_profiles (id BIGINT NOT NULL PRIMARY KEY, key_id BIGINT NOT NULL, CONSTRAINT fk_key_profiles_access_keys FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE key_events (id BIGINT NOT NULL PRIMARY KEY, key_id BIGINT NOT NULL, CONSTRAINT fk_key_events_access_keys FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE hardware_tokens (id BIGINT NOT NULL PRIMARY KEY, key_id BIGINT NOT NULL, CONSTRAINT fk_hardware_tokens_access_keys FOREIGN KEY (key_id) REFERENCES access_keys(key_id));
CREATE TABLE mobile_links (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, user_id BIGINT, CONSTRAINT fk_mobile_links_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), CONSTRAINT fk_mobile_links_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE permission_events (id BIGINT NOT NULL PRIMARY KEY, user_id BIGINT NOT NULL, CONSTRAINT fk_permission_events_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE user_login_attempts (id BIGINT NOT NULL PRIMARY KEY, user_id BIGINT NOT NULL, CONSTRAINT fk_login_attempts_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE key_requests (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, user_id BIGINT, CONSTRAINT fk_key_requests_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), CONSTRAINT fk_key_requests_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE acls (id BIGINT NOT NULL PRIMARY KEY, principal_type INT NOT NULL, principal_id BIGINT NOT NULL);
CREATE TABLE ledger_accounts (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_ledger_accounts_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE primary_ledgers (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_primary_ledgers_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE ledger_operations (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_ledger_operations_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE ledger_snapshots (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_ledger_snapshots_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE user_ledgers (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, user_id BIGINT NOT NULL, external_ref VARCHAR(64), CONSTRAINT fk_user_ledgers_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id), CONSTRAINT fk_user_ledgers_user_accounts FOREIGN KEY (user_id) REFERENCES user_accounts(id));
CREATE TABLE payment_plastics (plastic_id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_payment_plastics_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_limits (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, plastic_id BIGINT NOT NULL, CONSTRAINT fk_plastic_limits_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id), CONSTRAINT fk_plastic_limits_cards FOREIGN KEY (plastic_id) REFERENCES payment_plastics(plastic_id));
CREATE TABLE plastic_snapshots (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_plastic_snapshots_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_operations (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_plastic_operations_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE plastic_ledgers (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_plastic_ledgers_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES ledger_accounts(id));
CREATE TABLE savings_contracts (savings_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_savings_contracts_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE savings_ledgers (ledger_id BIGINT NOT NULL PRIMARY KEY, savings_id BIGINT NOT NULL, CONSTRAINT fk_savings_ledgers_info FOREIGN KEY (savings_id) REFERENCES savings_contracts(savings_id));
CREATE TABLE savings_operations (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_savings_operations_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES savings_ledgers(ledger_id));
CREATE TABLE savings_rate_events (id BIGINT NOT NULL PRIMARY KEY, ledger_id BIGINT NOT NULL, CONSTRAINT fk_savings_rate_events_ledger_accounts FOREIGN KEY (ledger_id) REFERENCES savings_ledgers(ledger_id));
CREATE TABLE loan_contracts (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_loan_contracts_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE loan_schedules (id BIGINT NOT NULL PRIMARY KEY, loan_id BIGINT NOT NULL, CONSTRAINT fk_loan_schedules_info FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_debt_snapshots (id BIGINT NOT NULL PRIMARY KEY, loan_id BIGINT NOT NULL, CONSTRAINT fk_loan_debt_snapshots_info FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_operations (id BIGINT NOT NULL PRIMARY KEY, loan_id BIGINT NOT NULL, CONSTRAINT fk_loan_operations_info FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_rate_events (id BIGINT NOT NULL PRIMARY KEY, loan_id BIGINT NOT NULL, CONSTRAINT fk_loan_rate_events_info FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE loan_segments (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, loan_id BIGINT NOT NULL, loan_external_ref VARCHAR(64), CONSTRAINT fk_loan_segments_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id), CONSTRAINT fk_loan_segments_info FOREIGN KEY (loan_id) REFERENCES loan_contracts(id));
CREATE TABLE document_events (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL);
CREATE TABLE document_recipients (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL, recipient_subject_id BIGINT NOT NULL, recipient_kind INT NOT NULL);
CREATE TABLE savings_documents (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL);
CREATE TABLE inbox_messages (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_inbox_messages_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payroll_batches (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_payroll_batches_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payroll_slips (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_payroll_slips_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE savings_open_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_savings_open_requests_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE card_open_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_card_open_requests_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rule_create_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_reg_payment_creation_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rule_stop_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_reg_payment_disabling_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE transfer_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_transfer_requests_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE currency_payment_requests (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_currency_payment_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE delivery_rejects (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_delivery_rejects_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE card_funding_deliveries (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_card_funding_deliveries_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_rules (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_regular_payments_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_sale_documents (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_reg_sale_doc_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_sale_rows (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL, CONSTRAINT fk_reg_sale_rows_documents FOREIGN KEY (document_id) REFERENCES regulatory_sale_documents(document_id));
CREATE TABLE regulatory_payment_documents (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_reg_payment_doc_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_payment_rows (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL, CONSTRAINT fk_reg_payment_rows_documents FOREIGN KEY (document_id) REFERENCES regulatory_payment_documents(document_id));
CREATE TABLE regulatory_tax_documents (document_id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_reg_tax_doc_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE regulatory_tax_rows (id BIGINT NOT NULL PRIMARY KEY, document_id BIGINT NOT NULL, CONSTRAINT fk_reg_tax_rows_documents FOREIGN KEY (document_id) REFERENCES regulatory_tax_documents(document_id));
CREATE TABLE subject_operation_links (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_subject_operation_links_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE network_rules (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_network_rules_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE admin_subject_links (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_admin_subject_links_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE document_watchers (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_document_watchers_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE session_windows (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_session_windows_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE org_positions (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_org_positions_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE budget_items (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_budget_items_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE payment_recipients (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_payment_recipients_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE approved_recipients (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_approved_recipients_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE beneficiary_profiles (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_beneficiary_profiles_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE message_links (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_message_links_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE subject_properties (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_subject_properties_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE corporate_recipients (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_corporate_recipients_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE mobile_recipients (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_mobile_recipients_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE trusted_payment_caps (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_tplimit2subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE currency_agents (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_currency_agents_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE onboarding_attachments (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_onboarding_attachments_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));
CREATE TABLE subject_status_events (id BIGINT NOT NULL PRIMARY KEY, subject_id BIGINT NOT NULL, CONSTRAINT fk_subject_status_events_subjects FOREIGN KEY (subject_id) REFERENCES subjects(subject_id));










