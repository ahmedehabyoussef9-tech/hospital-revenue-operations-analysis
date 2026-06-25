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
    email varchar (40)
);


CREATE TABLE patients (
	patient_id varchar (25) primary key,
    first_name varchar (50),
    last_name varchar (50),
    gender varchar (5),
    date_of_birth date,
    contact_number varchar (30),
    address varchar (80),
    registration_date date,
    insurance_provider varchar (50),
    insurance_number varchar (50),
    email varchar (40)
    );
    
    CREATE TABLE appointments (
	appointment_id varchar (50) primary key,
    patient_id varchar (50),
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
    patient_id varchar (50),
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
SELECT t.treatment_type, SUM(b.amount) AS revenue
FROM treatments t
JOIN billing b
ON t.treatment_id = b.treatment_id
GROUP BY t.treatment_type
ORDER BY revenue DESC;

-- Chemotherapy, MRI, and X-Ray r the highest services that generate revenue

-- Which patients have unpaid bills?

SELECT *
FROM billing
WHERE payment_status = 'Pending' 
OR payment_status = 'Failed';

-- seems like there are a ton of pending & failed payments, so it would be better to standarize one payment method 

-- which patients spent the most money?

SELECT patient_id, SUM(amount) AS total_spent
FROM billing
GROUP BY patient_id
ORDER BY total_spent DESC;

-- patient with id P012 spent by far the most (30k) 
-- even compared to 2nd spot P049 (23k) its still relatively higher

-- how much unpaid revenue exist?
SELECT SUM(amount) AS unpaid_amount
FROM billing
WHERE payment_status IN ('Pending', 'Failed');
-- the total unpaid amount is 377824.95

-- how much paid revenue exist?
SELECT SUM(amount) AS paid_amount
FROM billing
WHERE payment_status = 'Paid';
-- the total paid amount is 173424.90, which is less than half the unpaid amount

-- Payment method distribution
SELECT payment_method, COUNT(*) AS total
FROM billing
GROUP BY payment_method
ORDER BY total DESC;
-- the favourite paying method for patients is Credid card with total of 75, then Inusrance with 64, and lastly Cash with 61

-- which doctors have highest average treatment cost?
SELECT a.doctor_id, avg(t.cost) AS AVG_Cost
FROM treatments t
JOIN appointments a
ON t.appointment_id = a.appointment_id
GROUP BY a.doctor_id
ORDER BY AVG_Cost DESC;
-- The average cost between doctors is relatively close, the difference between D008 which is the highest with 3339 and 
-- D008 which is the highest with 3339 and  the lowest D009 with 2202 is almost 1k

-- Appointments cancellation rate
SELECT status, COUNT(status) AS total
FROM appointments
GROUP BY status
ORDER BY total DESC;
-- from 200 appointments only 46 were Completed, 51 Scheduled, 51 Cancelled, and 52 No-show

-- Which specialization generates most revenue?
SELECT d.specialization, SUM(b.amount) AS total_revenue
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
JOIN treatments	t
ON a.appointment_id = t.appointment_id
JOIN billing b
ON t.treatment_id = b.treatment_id
GROUP BY d.specialization
ORDER BY total_revenue DESC;
-- It seems that Pediatrics generate the most revenue with 258k which is not far
--  from Dermatology whom make 202k, meanwhile Oncology is far behind both with 89k 

-- Most common reasons for visit
SELECT reason_for_visit, COUNT(reason_for_visit) AS total
FROM appointments
GROUP BY reason_for_visit
ORDER BY total DESC;
-- Emergency comes last by far for visiting reasons with 29 known that the closest reason is 
-- Follow-up with 41, reason is Follow-up with 41, and the most visiting reason is Checkup with 45 

-- Gender distribution of patients
SELECT gender, COUNT(gender) AS total
FROM patients
GROUP BY gender;
-- most our patients are males with 31 compared to femlaes (19)

-- Age distribution
SELECT
patient_id,
YEAR('2024-12-31') - YEAR(date_of_birth) AS age
FROM patients;

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
-- all age groups r relatively close, coming in at the top is the 18-35 group with 20 person, then 50+ with 18, and lastly the 36-50 with 12 


-- Insurance provider usage
SELECT insurance_provider, COUNT(*) AS total
FROM patients
GROUP BY insurance_provider
ORDER BY total DESC;
-- MedCare Plus comes first with 18 user, right behind it is WelnessCorp with 16 user
-- then comes a noticable drop for PulseSecure with 10 users, and lastly HealthIndia with only 6 users

