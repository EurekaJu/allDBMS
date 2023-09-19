--****PLEASE ENTER YOUR DETAILS BELOW****
--cgh_queries.sql

--Student ID:30391113
--Student Name:An Ju
--Tutorial No: 07

/* Comments for your marker:
Only doctor have doctor id, so procedure performed by technician will be null in perform_dr_id



*/


/*
    Q1
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT
    doctor_title,
    doctor_fname,
    doctor_lname,
    doctor_phone
FROM
    (
        (
                 cgh.doctor d
            JOIN cgh.doctor_speciality    ds
            ON d.doctor_id = ds.doctor_id
        )
        JOIN cgh.speciality           s
        ON ds.spec_code = s.spec_code
    )
WHERE
    s.spec_description = 'Orthopedic surgery'
ORDER BY
    doctor_lname,
    doctor_fname;

/*
    Q2
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    item_code,
    item_description,
    item_stock,
    cc_title
FROM
         cgh.item i
    JOIN cgh.costcentre c
    ON i.cc_code = c.cc_code
WHERE
        item_stock > 50
    AND item_description LIKE '%Disposable%'
ORDER BY
    item_code;

/*
    Q3
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    p.patient_id,
    CASE
        WHEN patient_fname IS NULL THEN
            patient_lname
        ELSE
            patient_fname
            || ' '
            || patient_lname
    END                                                      AS "Patient Name",
    to_char(adm_date_time, 'DD/MON/YYYY HH12:MI:SS AM')      AS adm_date_time,
    CASE
        WHEN doctor_fname IS NULL THEN
            doctor_title
            || '. '
            || doctor_lname
        ELSE
            doctor_title
            || '. '
            || doctor_fname
            || ' '
            || doctor_lname
    END                                                      AS "Doctor Name"
FROM
    (
             cgh.doctor d
        JOIN cgh.admission    a
        ON d.doctor_id = a.doctor_id
    )
    JOIN cgh.patient      p
    ON a.patient_id = p.patient_id
WHERE
    adm_date_time BETWEEN TO_DATE('11/SEP/2021 10:00:00 AM', 'DD/MON/YYYY HH12:MI:SS AM')
    AND TO_DATE('14/SEP/2021 06:00:00 PM', 'DD/MON/YYYY HH12:MI:SS AM')
ORDER BY
    adm_date_time;
/*
    Q4
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    proc_code,
    proc_name,
    proc_description,
    to_char(proc_std_cost, '$9999.99') AS proc_std_cost
FROM
    cgh.procedure
WHERE
    proc_std_cost < (
        SELECT
            AVG(proc_std_cost)
        FROM
            cgh.procedure
    )
ORDER BY
    proc_std_cost DESC;

/*
    Q5
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    p.patient_id,
    patient_lname,
    patient_fname,
    to_char(patient_dob, 'dd/MON/yyyy')       AS patient_dob,
    COUNT(adm_no)                            AS adm_times
FROM
         cgh.patient p
    JOIN cgh.admission a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    patient_lname,
    patient_fname,
    patient_dob
HAVING
    COUNT(adm_no) > 2
ORDER BY
    adm_times DESC,
    patient_dob;

/*
    Q6
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer

SELECT
    adm_no,
    p.patient_id,
    patient_fname,
    patient_lname,
    CASE
        WHEN to_number(adm_discharge - adm_date_time) - floor(to_number(adm_discharge -
        adm_date_time)) = 0 THEN
            to_char(floor(to_number(adm_discharge - adm_date_time)))
            || ' days'
        ELSE
            to_char(floor(to_number(adm_discharge - adm_date_time)))
            || ' days '
            || to_char((to_number(adm_discharge - adm_date_time) - floor(to_number(adm_discharge -
            adm_date_time))) * 24,
                       '99.9')
            || ' hrs'
    END AS hospital_times
FROM
         cgh.admission a
    JOIN cgh.patient p
    ON a.patient_id = p.patient_id
WHERE
    adm_discharge IS NOT NULL
    AND to_char(adm_discharge - adm_date_time) > (
        SELECT
            AVG(adm_discharge - adm_date_time)
        FROM
            cgh.admission
        WHERE
            adm_discharge IS NOT NULL
    )
ORDER BY
    patient_dob;

/*
    Q7
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    pr.proc_code,
    proc_name,
    proc_description,
    proc_time,
    to_char(proc_std_cost, '$9999.00') AS proc_std_cost,
    to_char(AVG(adprc_pat_cost) - proc_std_cost, '9999.99') AS proc_price_diff
FROM
         cgh.procedure pr
    JOIN cgh.adm_prc ap
    ON pr.proc_code = ap.proc_code
WHERE
    perform_dr_id IS NOT NULL
GROUP BY
    pr.proc_code,
    proc_name,
    proc_description,
    proc_time,
    proc_std_cost
ORDER BY
    proc_code;



/*
    Q8
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    p.proc_code,
    proc_name,
    CASE
        WHEN i.item_code IS NULL THEN
            '---'
        ELSE
            i.item_code
    END  AS item_code,
    CASE
        WHEN item_description IS NULL THEN
            '---'
        ELSE
            item_description
    END  AS item_description,
    CASE
        WHEN MAX(to_char(it_qty_used)) IS NULL THEN
            '---'
        ELSE
            MAX(to_char(it_qty_used))
    END  AS it_qty_used
FROM
    cgh.procedure         p
    LEFT OUTER JOIN (
        (
                 cgh.adm_prc ap
            JOIN cgh.item_treatment    it
            ON ap.adprc_no = it.adprc_no
        )
        JOIN cgh.item              i
        ON it.item_code = i.item_code
    )
    ON p.proc_code = ap.proc_code
GROUP BY
    p.proc_code,
    proc_name,
    i.item_code,
    item_description
ORDER BY
    proc_name,
    item_code;

/*
    Q9a (FIT2094 only) or Q9b (FIT3171 only)
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT
    p.proc_code,
    proc_name,
    CASE
        WHEN perform_dr_id IS NULL THEN
            '----'
        ELSE
            to_char(perform_dr_id)
    END                                                          AS perform_dr_id,
    CASE
        WHEN doctor_fname IS NULL
             AND doctor_lname IS NULL THEN
            'Technician'
        ELSE
            CASE
                WHEN doctor_fname IS NULL THEN
                        doctor_title
                        || '. '
                        || doctor_lname
                ELSE
                    doctor_title
                    || '. '
                    || doctor_fname
                    || ' '
                    || doctor_lname
            END
    END                                                          AS "Doctor Name",
    to_char(MAX(to_char(adprc_pat_cost)), '$9999.99')             AS adprc_pat_cost
FROM
    (
             cgh.procedure p
        JOIN cgh.adm_prc    ap
        ON p.proc_code = ap.proc_code
    )
    LEFT OUTER JOIN cgh.doctor     d
    ON ap.perform_dr_id = d.doctor_id
GROUP BY
    p.proc_code,
    proc_name,
    perform_dr_id,
    doctor_id,
    doctor_fname,
    doctor_lname,
    doctor_title
ORDER BY
    p.proc_code,
    d.doctor_id;
