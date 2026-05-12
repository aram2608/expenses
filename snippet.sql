Update individual fields:
-- note
UPDATE expenses SET note = 'new note' WHERE id = ?;

-- tag
UPDATE expenses SET tag = 'groceries' WHERE id = ?;

-- amount (in cents, assuming that's how you store it)
UPDATE expenses SET amount = 1500 WHERE id = ?;

-- date
UPDATE expenses SET date = '2026-05-10' WHERE id = ?;
