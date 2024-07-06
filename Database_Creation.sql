CREATE TABLE Citizen (
  cin integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name_first varchar(255) NOT NULL,
  name_last varchar(255) NOT NULL,
  dob date NOT NULL,
  ad_doorno varchar(255) NOT NULL,
  ad_street varchar(255) NOT NULL,
  ad_pincode decimal(6) NOT NULL,
  income float NOT NULL
);

CREATE VIEW Citizen_income_category AS
SELECT income,
CASE
  WHEN income < 300000 THEN 'EWS'
  WHEN income < 600000 THEN 'LIG'
  WHEN income < 180000 THEN 'MIG'
  ELSE 'HIG'
END AS income_category
FROM Citizen;

CREATE VIEW Citizen_tax AS
SELECT income, 
CASE
  WHEN income_category = 'LIG' THEN 0.1 * income
  WHEN income_category = 'MIG' THEN 0.2 * income
  WHEN income_category = 'HIG' THEN 0.3 * income
  ELSE 0
END AS income_tax
FROM Citizen_income_category;

CREATE TABLE LEA (
  lea_code integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name_area varchar(255) NOT NULL,
  name_dept varchar(255) NOT NULL,
  budget float NOT NULL
);

CREATE TABLE LEA_employees (
  employees integer NOT NULL,
  lea_code integer NOT NULL,
  PRIMARY KEY (lea_code, employees)
);

CREATE TABLE LEA_cases (
  lea_code integer NOT NULL,
  cases varchar(255) NOT NULL,
  PRIMARY KEY (lea_code, cases)
);

CREATE TABLE Hospitals (
  nmpi integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  cap_icu integer NOT NULL,
  cap_surgery integer NOT NULL,
  cap_pediatric integer NOT NULL,
  cap_clinic integer NOT NULL,
  budget_allocated float NOT NULL
);

CREATE TABLE Hospitals_doctors (
  nmpi integer NOT NULL,
  doctors integer NOT NULL,
  PRIMARY KEY (nmpi, doctors)
);

CREATE TABLE Hospitals_nurses (
  nmpi integer NOT NULL,
  nurses integer NOT NULL,
  PRIMARY KEY (nmpi, nurses)
);

CREATE TABLE Hospitals_staff (
  nmpi integer NOT NULL,
  staff integer NOT NULL,
  PRIMARY KEY (nmpi, staff)
);

CREATE TABLE Neighbourhood (
  representative integer,
  pincode decimal(6) PRIMARY KEY NOT NULL,
  type varchar(255)
);

CREATE TABLE Neighbourhood_landmark (
  pincode decimal(6) NOT NULL,
  landmark varchar(255) NOT NULL,
  PRIMARY KEY (pincode, landmark)
);

CREATE TABLE Bank (
  bank_code integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  cost_employee float NOT NULL,
  cost_infra float NOT NULL,
  cost_interest float NOT NULL,
  cost_repo float NOT NULL,
  rev_loan float NOT NULL,
  rev_asset float NOT NULL,
  rev_dividends float NOT NULL
);

CREATE TABLE Bank_interests (
  bank_code integer NOT NULL,
  interest_rates float NOT NULL,
  PRIMARY KEY (bank_code, interest_rates)
);

CREATE TABLE Crimes (
  lea integer NOT NULL,
  victim_cin integer NOT NULL,
  suspect_cin integer NOT NULL,
  neighbourhood decimal(6) NOT NULL,
  fir_no integer PRIMARY KEY NOT NULL AUTO_INCREMENT
);

CREATE TABLE Crimes_inspector (
  inspector integer NOT NULL,
  fir_no integer NOT NULL,
  PRIMARY KEY (fir_no, inspector)
);

CREATE TABLE Crimes_crimetype (
  fir_no integer,
  crimetype varchar(255),
  PRIMARY KEY (fir_no, crimetype)
);

CREATE TABLE Crimes_charges (
  fir_no integer NOT NULL,
  charges varchar(255) NOT NULL,
  PRIMARY KEY (fir_no, charges)
);

CREATE TABLE Patients (
  nmpi integer NOT NULL,
  cin integer NOT NULL,
  patient_id integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  treatment_cost float NOT NULL
);

CREATE TABLE Patients_diseases (
  patient_id integer NOT NULL,
  diseases varchar(255) NOT NULL,
  PRIMARY KEY (patient_id, diseases)
);

CREATE TABLE Patients_doctors (
  patient_id integer NOT NULL,
  doctors integer NOT NULL,
  PRIMARY KEY (patient_id, doctors)
);

CREATE TABLE BankAccount (
  account_id integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
  bank_code integer NOT NULL,
  cin integer NOT NULL,
  nominee integer NOT NULL,
  money_deposited float NOT NULL
);

CREATE TABLE R_serves (
  nmpi integer NOT NULL,
  pincode decimal(6) NOT NULL,
  PRIMARY KEY (nmpi, pincode)
);

CREATE TABLE R_loan_bank (
  bank_code integer NOT NULL,
  loan_bank integer NOT NULL,
  loan_amount float NOT NULL,
  interest_rate float NOT NULL,
  repayment_method varchar(255) NOT NULL,
  PRIMARY KEY (bank_code, loan_bank)
);

CREATE TABLE R_loan_citizen (
  bank_code integer NOT NULL,
  loan_citizen integer NOT NULL,
  loan_amount float NOT NULL,
  interest_rate float NOT NULL,
  repayment_method varchar(255) NOT NULL,
  PRIMARY KEY (bank_code, loan_citizen)
);

CREATE TABLE R_loan_hospital (
  bank_code integer NOT NULL,
  loan_hospital integer NOT NULL,
  loan_amount float NOT NULL,
  interest_rate float NOT NULL,
  repayment_method varchar(255) NOT NULL,
  PRIMARY KEY (bank_code, loan_hospital)
);

CREATE TABLE R_loan_lea (
  bank_code integer NOT NULL,
  loan_lea integer NOT NULL,
  loan_amount float NOT NULL,
  interest_rate float NOT NULL,
  repayment_method varchar(255) NOT NULL,
  PRIMARY KEY (bank_code, loan_lea)
);

ALTER TABLE LEA_employees ADD FOREIGN KEY (employees) REFERENCES Citizen (cin);
ALTER TABLE LEA_employees ADD FOREIGN KEY (lea_code) REFERENCES LEA (lea_code) ON DELETE CASCADE;
ALTER TABLE LEA_cases ADD FOREIGN KEY (lea_code) REFERENCES LEA (lea_code) ON DELETE CASCADE;

ALTER TABLE Hospitals_doctors ADD FOREIGN KEY (nmpi) REFERENCES Hospitals (nmpi) ON DELETE CASCADE;
ALTER TABLE Hospitals_doctors ADD FOREIGN KEY (doctors) REFERENCES Citizen (cin);
ALTER TABLE Hospitals_nurses ADD FOREIGN KEY (nmpi) REFERENCES Hospitals (nmpi) ON DELETE CASCADE;
ALTER TABLE Hospitals_nurses ADD FOREIGN KEY (nurses) REFERENCES Citizen (cin);
ALTER TABLE Hospitals_staff ADD FOREIGN KEY (nmpi) REFERENCES Hospitals (nmpi) ON DELETE CASCADE;
ALTER TABLE Hospitals_staff ADD FOREIGN KEY (staff) REFERENCES Citizen (cin);

ALTER TABLE Neighbourhood ADD FOREIGN KEY (representative) REFERENCES Citizen (cin);
ALTER TABLE Neighbourhood_landmark ADD FOREIGN KEY (pincode) REFERENCES Neighbourhood (pincode) ON DELETE CASCADE;

ALTER TABLE Bank_interests ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code) ON DELETE CASCADE;

ALTER TABLE Crimes ADD FOREIGN KEY (lea) REFERENCES LEA (lea_code);
ALTER TABLE Crimes ADD FOREIGN KEY (victim_cin) REFERENCES Citizen (cin);
ALTER TABLE Crimes ADD FOREIGN KEY (suspect_cin) REFERENCES Citizen (cin);
ALTER TABLE Crimes ADD FOREIGN KEY (neighbourhood) REFERENCES Neighbourhood (pincode);
ALTER TABLE Crimes_inspector ADD FOREIGN KEY (inspector) REFERENCES Citizen (cin);
ALTER TABLE Crimes_inspector ADD FOREIGN KEY (fir_no) REFERENCES Crimes (fir_no) ON DELETE CASCADE;
ALTER TABLE Crimes_crimetype ADD FOREIGN KEY (fir_no) REFERENCES Crimes (fir_no) ON DELETE CASCADE;
ALTER TABLE Crimes_charges ADD FOREIGN KEY (fir_no) REFERENCES Crimes (fir_no) ON DELETE CASCADE;

ALTER TABLE Patients ADD FOREIGN KEY (nmpi) REFERENCES Hospitals (nmpi);
ALTER TABLE Patients ADD FOREIGN KEY (cin) REFERENCES Citizen (cin);
ALTER TABLE Patients_diseases ADD FOREIGN KEY (patient_id) REFERENCES Patients (patient_id) ON DELETE CASCADE;
ALTER TABLE Patients_doctors ADD FOREIGN KEY (patient_id) REFERENCES Patients (patient_id) ON DELETE CASCADE;
ALTER TABLE Patients_doctors ADD FOREIGN KEY (doctors) REFERENCES Citizen (cin);

ALTER TABLE BankAccount ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code);
ALTER TABLE BankAccount ADD FOREIGN KEY (cin) REFERENCES Citizen (cin);

ALTER TABLE Citizen ADD CONSTRAINT R_lives_in FOREIGN KEY (ad_pincode) REFERENCES Neighbourhood (pincode);

ALTER TABLE R_serves ADD FOREIGN KEY (nmpi) REFERENCES Hospitals (nmpi) ON DELETE CASCADE;
ALTER TABLE R_serves ADD FOREIGN KEY (pincode) REFERENCES Neighbourhood (pincode) ON DELETE CASCADE;

ALTER TABLE R_loan_bank ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code);
ALTER TABLE R_loan_bank ADD FOREIGN KEY (loan_bank) REFERENCES Bank (bank_code);

ALTER TABLE R_loan_citizen ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code);
ALTER TABLE R_loan_citizen ADD FOREIGN KEY (loan_citizen) REFERENCES Citizen (cin);

ALTER TABLE R_loan_hospital ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code);
ALTER TABLE R_loan_hospital ADD FOREIGN KEY (loan_hospital) REFERENCES Hospitals (nmpi);

ALTER TABLE R_loan_lea ADD FOREIGN KEY (bank_code) REFERENCES Bank (bank_code);
ALTER TABLE R_loan_lea ADD FOREIGN KEY (loan_lea) REFERENCES LEA (lea_code);


INSERT INTO Neighbourhood VALUES
(NULL, 510001, 'Residential'),
(NULL, 510002, 'Residential'),
(NULL, 510003, 'Commercial'),
(NULL, 510004, 'Industrial'),
(NULL, 510005, 'Commercial');

INSERT INTO Citizen(name_first, name_last, dob, ad_doorno, ad_street, ad_pincode, income) VALUES 
('John', 'Doe', '1990-01-15', '123 Velvet Vista', 'Abbey road', 510001, 500000.00),
('Lilly', 'Doe', '1990-03-13', '123 Velvet Vista', 'Abbey road', 510001, 200000.00),
('James', 'Doe', '1969-09-25', '123 Velvet Vista', 'Abbey road', 510001, 100000.00),
('Jane', 'Smith', '1985-05-20', '456 Iris Indigo', 'Muller road', 510002, 750000.00),
('Alice', 'Johnson', '1998-09-08', '789 Celestial Citadel', 'Abaco path', 510001, 200000.00),
('Bob', 'Williams', '1980-03-12', '101 Ocean Shores', 'Hazel road', 510003, 3000000.00),
('Eva', 'Anderson', '1995-07-03', '202 Cedar Vu', 'Abbey road', 510002, 5000000.00),
('Willaim', 'Prince', '1991-01-14', '342 Velvet Vista', 'Abbey road', 510001, 600000.00),
('Jennifer', 'Smith', '1982-05-23', '543 Iris Indigo', 'Muller road', 510002, 150000.00),
('Daniel', 'Brigde', '1999-03-15', '234 Celestial Citadel', 'Abaco path', 510001, 250000.00),
('Elon', 'Paul', '1981-06-22', '342 Ocean Shores', 'Hazel road', 510003, 3300000.00),
('Emily', 'Paul', '1982-02-01', '342 Ocean Shores', 'Hazel road', 510003, 1000000.00),
('Raul', 'Cook', '1996-02-05', '104 Cedar Vu', 'Abbey road', 510002, 200000.00),
('Sian', 'Cook', '1998-09-20', '104 Cedar Vu', 'Abbey road', 510002, 5700000.00),
('James', 'Howard', '1991-01-14', '245 Velvet Vista', 'Abbey road', 510001, 600000.00),
('Lee', 'Biden', '1987-05-23', '135 Iris Indigo', 'Muller road', 510002, 150000.00),
('Jessica', 'Sanders', '1998-03-15', '168 Celestial Citadel', 'Abaco path', 510001, 250000.00);

INSERT INTO LEA(name_area, name_dept, budget) VALUES
('Downtown', 'Police', 10000000.00),
('Suburbia', 'Traffic', 7500000.00),
('Rural', 'Sheriff', 5000000.00),
('Metropolis', 'Detective', 12000000.00),
('City Center', 'Special Ops', 15000000.00);

INSERT INTO LEA_employees(lea_code, employees) VALUES
(1, 6),
(1, 7),
(2, 6),
(2, 7),
(3, 8),
(4, 6),
(5, 7);

INSERT INTO LEA_cases(lea_code, cases) VALUES
(1, 'Robbery'),
(2, 'Speeding Ticket'),
(2, 'Signal Jumping'),
(3, 'Burglary'),
(4, 'Homicide'),
(4, 'Terrorism'),
(5, 'Kidnapping');

INSERT INTO Hospitals(name, cap_icu, cap_surgery, cap_pediatric, cap_clinic, budget_allocated) VALUES
('City Hospital', 10, 5, 8, 20, 200000.00),
('Suburb Clinic', 5, 2, 4, 10, 75000.00),
('Rural Medical Center', 3, 1, 2, 5, 50000.00),
('Metropolis General', 15, 8, 10, 30, 300000.00),
('Central Health Hub', 20, 10, 15, 40, 400000.00);

INSERT INTO Hospitals_doctors VALUES
(1, 3),
(1, 4),
(2, 4),
(3, 3),
(4, 3),
(4, 4),
(4, 5),
(5, 4),
(5, 5);

INSERT INTO Hospitals_nurses VALUES
(1, 9),
(1, 11),
(2, 10),
(3, 9),
(4, 8),
(4, 10),
(4, 11),
(5, 11),
(5, 10);

INSERT INTO Hospitals_staff VALUES
(1, 12),
(2, 13),
(3, 13),
(4, 12),
(5, 12);

INSERT INTO Neighbourhood_landmark VALUES
(510001, 'City Park'),
(510001, 'Town hall'),
(510002, 'Shopping Mall'),
(510002, 'Train station'),
(510003, 'Factory Zone'),
(510004, 'Local Market'),
(510005, 'Business Center');

INSERT INTO Bank(cost_employee, cost_infra, cost_interest, cost_repo, rev_loan, rev_asset, rev_dividends) VALUES
(50000.00, 100000.00, 20000.00, 30000.00, 500000.00, 300000.00, 50000.00),
(30000.00, 80000.00, 15000.00, 20000.00, 400000.00, 200000.00, 30000.00),
(20000.00, 50000.00, 10000.00, 15000.00, 300000.00, 150000.00, 20000.00),
(60000.00, 120000.00, 25000.00, 35000.00, 700000.00, 400000.00, 60000.00),
(70000.00, 150000.00, 30000.00, 40000.00, 800000.00, 500000.00, 70000.00);

INSERT INTO Bank_interests VALUES
(1, 5.0),
(1, 6.0),
(2, 4.5),
(2, 5.5),
(3, 4.0),
(3, 5.0),
(4, 6.0),
(4, 6.5),
(5, 6.5),
(5, 7.0);

INSERT INTO Crimes(lea, victim_cin, suspect_cin, neighbourhood) VALUES
(1, 1, 11, 510001),
(1, 3, 12, 510001),
(2, 5, 10, 510002),
(2, 2, 11, 510003),
(3, 4, 14, 510002);

INSERT INTO Crimes_inspector VALUES
(16, 1),
(16, 2),
(17, 3),
(17, 4),
(16, 5);

INSERT INTO Crimes_crimetype VALUES
(1, 'Theft'),
(2, 'Theft'),
(3, 'Traffic Violation'),
(4, 'Traffic Violation'),
(5, 'Kidnapping');

INSERT INTO Crimes_charges VALUES
(1, 'Stealing'),
(2, 'Bulgarly'),
(3, 'Speeding'),
(4, 'Signal jumping'),
(5, 'Kidnapping');

INSERT INTO Patients(nmpi, cin, treatment_cost) VALUES
(1, 5, 50000.00),
(2, 2, 75000.00),
(3, 1, 60000.00),
(4, 3, 80000.00),
(5, 2, 55000.00);

INSERT INTO Patients_diseases VALUES
(1, 'Flu'),
(1, 'Diarrhoea'),
(2, 'Fracture'),
(3, 'Diabetes'),
(3, 'Hypertension'),
(4, 'Heart Attack'),
(5, 'Migraine'),
(5, 'Diabetes');

INSERT INTO Patients_doctors VALUES
(1, 3),
(2, 4),
(3, 3),
(4, 4),
(5, 3);

INSERT INTO BankAccount(bank_code, cin, nominee, money_deposited) VALUES
(1, 1, 1, 500000.00),
(2, 2, 2, 750000.00),
(3, 3, 3, 600000.00),
(4, 4, 4, 800000.00),
(5, 5, 5, 550000.00);

INSERT INTO R_serves VALUES
(1, 510001),
(2, 510002),
(3, 510003),
(4, 510004),
(5, 510005);

INSERT INTO R_loan_bank VALUES
(1, 2, 500000.00, 5.0, 1),
(2, 3, 300000.00, 4.5, 2),
(3, 4, 200000.00, 4.0, 1),
(4, 5, 600000.00, 6.0, 2),
(5, 1, 700000.00, 6.5, 1);

INSERT INTO R_loan_citizen VALUES
(1, 1, 50000.00, 5.0, 1),
(1, 6, 10000.00, 5.0, 1),
(2, 5, 75000.00, 4.5, 2),
(3, 2, 60000.00, 4.0, 1),
(3, 5, 90000.00, 4.0, 1),
(4, 10, 80000.00, 6.0, 2),
(5, 12, 55000.00, 6.5, 1);

INSERT INTO R_loan_hospital VALUES
(1, 1, 500000.00, 5.0, 1),
(2, 2, 300000.00, 4.5, 2),
(3, 3, 200000.00, 4.0, 1),
(3, 4, 600000.00, 6.0, 2),
(1, 5, 700000.00, 6.5, 1);

INSERT INTO R_loan_lea VALUES
(4, 1, 500000.00, 5.0, 1),
(2, 2, 300000.00, 4.5, 2),
(5, 3, 200000.00, 4.0, 1),
(4, 4, 600000.00, 6.0, 2),
(5, 5, 700000.00, 6.5, 1);
