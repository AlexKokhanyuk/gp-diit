CREATE INDEX xdl001 ON partner_agents(subject_id);
CREATE INDEX xdl002 ON agent_cards(agent_id);
CREATE INDEX xdl003 ON user_accounts(subject_id);
CREATE INDEX xdl004 ON access_keys(subject_id);
CREATE INDEX xdl005 ON access_keys(user_id);
CREATE INDEX xdl006 ON key_events(key_id);
CREATE INDEX xdl007 ON key_profiles(key_id);
CREATE INDEX xdl008 ON mobile_links(subject_id);
CREATE INDEX xdl009 ON permission_events(user_id);
CREATE INDEX xdl010 ON key_requests(subject_id);
CREATE INDEX xdl011 ON key_requests(user_id);
CREATE INDEX xdl012 ON ledger_accounts(subject_id);
CREATE INDEX xdl013 ON user_ledgers(ledger_id);
CREATE INDEX xdl014 ON user_ledgers(user_id);
CREATE INDEX xdl015 ON primary_ledgers(ledger_id);
CREATE INDEX xdl016 ON ledger_operations(ledger_id);
CREATE INDEX xdl017 ON ledger_snapshots(ledger_id);
CREATE INDEX xdl018 ON payment_plastics(ledger_id);
CREATE INDEX xdl019 ON plastic_limits(ledger_id);
CREATE INDEX xdl020 ON plastic_limits(plastic_id);
CREATE INDEX xdl021 ON loan_contracts(subject_id);
CREATE INDEX xdl022 ON loan_segments(subject_id);
CREATE INDEX xdl023 ON loan_schedules(loan_id);
CREATE INDEX xdl024 ON loan_debt_snapshots(loan_id);
CREATE INDEX xdl025 ON loan_operations(loan_id);
CREATE INDEX xdl026 ON loan_rate_events(loan_id);
CREATE INDEX xdl027 ON savings_contracts(subject_id);
CREATE INDEX xdl028 ON savings_ledgers(savings_id);
CREATE INDEX xdl029 ON savings_operations(ledger_id);
CREATE INDEX xdl030 ON savings_rate_events(ledger_id);
CREATE INDEX xdl031 ON document_events(document_id);
CREATE INDEX xdl032 ON document_recipients(document_id);
CREATE INDEX xdl033 ON document_recipients(recipient_subject_id, recipient_kind);
CREATE INDEX xdl034 ON savings_documents(document_id);
CREATE INDEX xdl035 ON inbox_messages(subject_id);
CREATE INDEX xdl036 ON payroll_batches(subject_id);
CREATE INDEX xdl037 ON payroll_slips(subject_id);
CREATE INDEX xdl038 ON savings_open_requests(subject_id);
CREATE INDEX xdl039 ON card_open_requests(subject_id);
CREATE INDEX xdl040 ON payment_rule_create_requests(subject_id);
CREATE INDEX xdl041 ON payment_rule_stop_requests(subject_id);
CREATE INDEX xdl042 ON transfer_requests(subject_id);
CREATE INDEX xdl043 ON currency_payment_requests(subject_id);
CREATE INDEX xdl044 ON delivery_rejects(subject_id);
CREATE INDEX xdl045 ON card_funding_deliveries(subject_id);
CREATE INDEX xdl046 ON regulatory_sale_documents(subject_id);
CREATE INDEX xdl047 ON regulatory_payment_documents(subject_id);
CREATE INDEX xdl048 ON regulatory_tax_documents(subject_id);
CREATE INDEX xdl049 ON trusted_payment_caps(subject_id);
CREATE INDEX xdl050 ON currency_agents(subject_id);










