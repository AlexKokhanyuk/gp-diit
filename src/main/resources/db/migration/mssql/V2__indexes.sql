CREATE INDEX xie_partner_agents_subject_id ON partner_agents(subject_id);
CREATE INDEX xie_agent_cards_agent_id ON agent_cards(agent_id);
CREATE INDEX xie_user_accounts_subject_id ON user_accounts(subject_id);
CREATE INDEX xie_access_keys_subject_id ON access_keys(subject_id);
CREATE INDEX xie_access_keys_user_id ON access_keys(user_id);
CREATE INDEX xie_key_events_key_id ON key_events(key_id);
CREATE INDEX xie_key_profiles_key_id ON key_profiles(key_id);
CREATE INDEX xie_mobile_links_subject_id ON mobile_links(subject_id);
CREATE INDEX xie_permission_events_user_id ON permission_events(user_id);
CREATE INDEX xie_key_requests_subject_id ON key_requests(subject_id);
CREATE INDEX xie_key_requests_user_id ON key_requests(user_id);
CREATE INDEX xie_ledger_accounts_subject_id ON ledger_accounts(subject_id);
CREATE INDEX xie_user_ledgers_ledger_id ON user_ledgers(ledger_id);
CREATE INDEX xie_user_ledgers_user_id ON user_ledgers(user_id);
CREATE INDEX xie_primary_ledgers_ledger_id ON primary_ledgers(ledger_id);
CREATE INDEX xie_ledger_operations_ledger_id ON ledger_operations(ledger_id);
CREATE INDEX xie_ledger_snapshots_ledger_id ON ledger_snapshots(ledger_id);
CREATE INDEX xie_payment_plastics_ledger_id ON payment_plastics(ledger_id);
CREATE INDEX xie_plastic_limits_ledger_id ON plastic_limits(ledger_id);
CREATE INDEX xie_plastic_limits_plastic_id ON plastic_limits(plastic_id);
CREATE INDEX xie_loan_contracts_subject_id ON loan_contracts(subject_id);
CREATE INDEX xie_loan_segments_subject_id ON loan_segments(subject_id);
CREATE INDEX xie_loan_schedules_loan_id ON loan_schedules(loan_id);
CREATE INDEX xie_loan_debt_snapshots_loan_id ON loan_debt_snapshots(loan_id);
CREATE INDEX xie_loan_operations_loan_id ON loan_operations(loan_id);
CREATE INDEX xie_loan_rate_events_loan_id ON loan_rate_events(loan_id);
CREATE INDEX xie_savings_contracts_subject_id ON savings_contracts(subject_id);
CREATE INDEX xie_savings_ledgers_savings_id ON savings_ledgers(savings_id);
CREATE INDEX xie_savings_operations_ledger_id ON savings_operations(ledger_id);
CREATE INDEX xie_savings_rate_events_ledger_id ON savings_rate_events(ledger_id);
CREATE INDEX xie_document_events_document_id ON document_events(document_id);
CREATE INDEX xie_document_recipients_document_id ON document_recipients(document_id);
CREATE INDEX xie_document_recipients_recipient ON document_recipients(recipient_subject_id, recipient_kind);
CREATE INDEX xie_savings_documents_document_id ON savings_documents(document_id);
CREATE INDEX xie_inbox_messages_subject_id ON inbox_messages(subject_id);
CREATE INDEX xie_payroll_batches_subject_id ON payroll_batches(subject_id);
CREATE INDEX xie_payroll_slips_subject_id ON payroll_slips(subject_id);
CREATE INDEX xie_savings_open_requests_subject_id ON savings_open_requests(subject_id);
CREATE INDEX xie_card_open_requests_subject_id ON card_open_requests(subject_id);
CREATE INDEX xie_reg_payment_creation_subject_id ON payment_rule_create_requests(subject_id);
CREATE INDEX xie_reg_payment_disabling_subject_id ON payment_rule_stop_requests(subject_id);
CREATE INDEX xie_transfer_requests_subject_id ON transfer_requests(subject_id);
CREATE INDEX idx_currency_payment_subject ON currency_payment_requests(subject_id);
CREATE INDEX xie_delivery_rejects_subject_id ON delivery_rejects(subject_id);
CREATE INDEX xie_card_funding_deliveries_subject_id ON card_funding_deliveries(subject_id);
CREATE INDEX idx_reg_sale_documents_subject ON regulatory_sale_documents(subject_id);
CREATE INDEX idx_reg_payment_documents_subject ON regulatory_payment_documents(subject_id);
CREATE INDEX idx_reg_tax_documents_subject ON regulatory_tax_documents(subject_id);
CREATE INDEX xie_trusted_payment_caps_subject_id ON trusted_payment_caps(subject_id);
CREATE INDEX xie_currency_agents_subject_id ON currency_agents(subject_id);










