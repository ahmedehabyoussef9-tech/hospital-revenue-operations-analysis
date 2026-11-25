CREATE DATABASE hospital_project;

USE hospital_project;

CREATE TABLE doctors (
	doctor_id varchar (25) primary key,
    first_name varchar (50),
    last_name varchar (50),
    specialization varchar (80),
    phone_number varchar (30),
    years_experience int,
    hospital_branch varchar (50),
    email varchar (225)
);


CREATE TABLE patients (
	patient_id varchar (25) primary key,
    first_name varchar (50),
    last_name varchar (50),
    gender varchar (10),
    date_of_birth date,
    contact_number varchar (30),
    address varchar (80),
    registration_date date,
    insurance_provider varchar (50),
    insurance_number varchar (50),
    email varchar (255)
    );
    
    CREATE TABLE appointments (
	appointment_id varchar (50) primary key,
    patient_id varchar (25),
    doctor_id varchar (25),
    appointment_date date,
    appointment_time time,
    reason_for_visit varchar (80),
    status varchar (70),
    
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

CREATE TABLE treatments (
	treatment_id varchar (50) primary key,
    appointment_id varchar (50),
    treatment_type varchar (50),
    description varchar (80),
    cost decimal (10,2),
    treatment_date date,
    
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

CREATE TABLE billing (
	bill_id varchar (50) primary key,
    patient_id varchar (25),
    treatment_id varchar (50),
    bill_date date,
    amount decimal (10,2),
    payment_method varchar (50),
    payment_status varchar (60),
    
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id)
);

-- Which doctors handle the most appointments?
SELECT doctor_id, COUNT(*) AS total_appointments
FROM appointments
GROUP BY doctor_id
ORDER BY total_appointments DESC;
-- Doctors D005, D001, and D006 carry the highest appointment workload.

-- Which treatment types generate most revenue?
SELECT t.treatment_type, SUM(b.amount) AS total_billed_amount
FROM treatments t
JOIN billing b
ON t.treatment_id = b.treatment_id
GROUP BY t.treatment_type
ORDER BY total_billed_amount DESC;

-- Chemotherapy, MRI, and X-Ray have the highest billed amounts.

-- Which patients have unpaid bills?

SELECT *
FROM billing
WHERE payment_status = 'Pending' 
OR payment_status = 'Failed';

-- A considerable number of bills are marked Pending or Failed.
-- Further analysis is needed to identify potential payment collection issues.

-- which patients spent the most money?

SELECT patient_id, SUM(amount) AS total_billed_amount
FROM billing
GROUP BY patient_id
ORDER BY total_billed_amount DESC;

-- Patient P012 has the highest total billed amount (approximately $30K),
-- followed by P049 (approximately $23K).

-- What is the total billed amount marked Pending or Failed?
SELECT SUM(amount) AS unpaid_amount
FROM billing
WHERE payment_status IN ('Pending', 'Failed');
-- Total billed amount marked Pending or Failed: $377,824.95.

-- What is the total billed amount marked Paid?
SELECT SUM(amount) AS paid_amount
FROM billing
WHERE payment_status = 'Paid';
-- Total billed amount marked Paid: $173,424.90.

-- Payment method distribution
SELECT payment_method, COUNT(*) AS total
FROM billing
GROUP BY payment_method
ORDER BY total DESC;
-- Credit Card is the most frequently used payment method (75 bills),
-- followed by Insurance (64) and Cash (61).

-- Payment status distribution by payment method
SELECT
    payment_method,
    payment_status,
    COUNT(*) AS total_bills,
    SUM(amount) AS total_billed_amount
FROM billing
GROUP BY payment_method, payment_status
ORDER BY payment_method, payment_status;

-- Which doctors have the highest average billed amount per appointment?
SELECT
    doctor_id,
    AVG(appointment_billed_amount) AS avg_billed_amount_per_appointment
FROM (
    SELECT
        a.appointment_id,
        a.doctor_id,
        SUM(b.amount) AS appointment_billed_amount
    FROM appointments a
    JOIN treatments t
        ON a.appointment_id = t.appointment_id
    JOIN billing b
        ON t.treatment_id = b.treatment_id
    GROUP BY a.appointment_id, a.doctor_id
) AS appointment_totals
GROUP BY doctor_id
ORDER BY avg_billed_amount_per_appointment DESC;

-- Doctor D008 recorded the highest average billed amount per appointment,
-- followed by D007 and D006.

-- Appointment status distribution
SELECT status, COUNT(status) AS total
FROM appointments
GROUP BY status
ORDER BY total DESC;
-- Out of 200 appointments:
-- 46 Completed, 51 Scheduled, 51 Cancelled, and 52 No-show.

-- Which specialization generates most revenue?
SELECT d.specialization, SUM(b.amount) AS total_billed_amount
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
JOIN treatments	t
ON a.appointment_id = t.appointment_id
JOIN billing b
ON t.treatment_id = b.treatment_id
GROUP BY d.specialization
ORDER BY total_billed_amount DESC;
-- Pediatrics has the highest total billed amount (approximately $258K),
-- followed by Dermatology ($202K) and Oncology ($89K).

-- Most common reasons for visit
SELECT reason_for_visit, COUNT(reason_for_visit) AS total
FROM appointments
GROUP BY reason_for_visit
ORDER BY total DESC;
-- Checkup is the most common visit reason (45 appointments),
-- followed by Follow-up (41) and Emergency (29).

-- Gender distribution of patients
SELECT gender, COUNT(gender) AS total
FROM patients
GROUP BY gender;
-- The patient dataset contains 31 males and 19 females.

-- Age distribution
SELECT
CASE
	WHEN timestampdiff(YEAR, date_of_birth, '2024-12-31') < 18 THEN 'Under 18'
    WHEN timestampdiff(YEAR, date_of_birth, '2024-12-31') BETWEEN 18 AND 35 THEN '18-35'
    WHEN timestampdiff(YEAR, date_of_birth, '2024-12-31') BETWEEN 36 AND 50 THEN '36-50'
    ELSE '50+'
END AS age_group,
COUNT(*) AS total
FROM patients
GROUP BY age_group;
-- The 18-35 age group is the largest (20 patients),
-- followed by 50+ (18) and 36-50 (12).


-- Insurance provider usage
SELECT insurance_provider, COUNT(*) AS total
FROM patients
GROUP BY insurance_provider
ORDER BY total DESC;
-- MedCare Plus is the most common insurance provider (18 patients),
-- followed by WellnessCorp (16), PulseSecure (10), and HealthIndia (6).

-- Overall billing summary by payment status
SELECT
    payment_status,
    COUNT(*) AS total_bills,
    SUM(amount) AS total_billed_amount,
    ROUND(
        SUM(amount) * 100.0 / (SELECT SUM(amount) FROM billing),
        2
    ) AS percentage_of_total
FROM billing
GROUP BY payment_status
ORDER BY total_billed_amount DESC;

