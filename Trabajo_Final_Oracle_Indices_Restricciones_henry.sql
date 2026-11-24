/*
=====================================================================
ASIGNATURA: Bases de Datos Avanzadas
TRABAJO: Índices y restricciones en Oracle (Esquema HR)
ALUMNO: Henry Alexander Valencia Castillo
FECHA: 23-11-2026
=====================================================================
*/

-- =====================================================================
-- 1. CONSULTAR LOS ÍNDICES DISPONIBLES EN LAS TABLAS
-- =====================================================================

-- Consultar índices de la tabla EMPLOYEES
SELECT INDEX_NAME, INDEX_TYPE, TABLE_NAME 
FROM USER_INDEXES 
WHERE TABLE_NAME = 'EMPLOYEES'; 

-- Consultar índices de la tabla DEPARTMENTS
SELECT INDEX_NAME, INDEX_TYPE, TABLE_NAME 
FROM USER_INDEXES 
WHERE TABLE_NAME = 'DEPARTMENTS';

-- =====================================================================
-- 2. DESACTIVAR LAS RESTRICCIONES DE ESTAS TABLAS
-- =====================================================================

-- Desactivar restricciones de DEPARTMENTS
ALTER TABLE departments DISABLE CONSTRAINT dept_id_pk CASCADE; 
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;

-- Desactivar restricciones de EMPLOYEES
ALTER TABLE employees DISABLE CONSTRAINT emp_emp_id_pk CASCADE; 
ALTER TABLE employees DISABLE CONSTRAINT emp_email_uk; 
ALTER TABLE employees DISABLE CONSTRAINT emp_dept_fk; 
ALTER TABLE employees DISABLE CONSTRAINT emp_job_fk; 
ALTER TABLE employees DISABLE CONSTRAINT emp_manager_fk; 
ALTER TABLE employees DISABLE CONSTRAINT emp_salary_min; 

-- =====================================================================
-- 3. INSERTAR TUPLAS QUE NO CUMPLAN LAS RESTRICCIONES
-- =====================================================================

-- 1. Insertar un empleado en un departamento que NO existe (ID 5555)
INSERT INTO employees (employee_id, last_name, email, hire_date, job_id, department_id) 
VALUES (7777, 'Violacion', 'VIOLACION', SYSDATE, 'IT_PROG', 5555); 

-- 2. Insertar un departamento con un manager que NO existe (ID 8888)
INSERT INTO departments (department_id, department_name, manager_id) 
VALUES (999, 'Dept Violacion', 8888); 

-- 3. Guardar los cambios
COMMIT; 

-- 4. Comprobar que se insertaron
SELECT employee_id, last_name, department_id FROM employees WHERE employee_id = 7777; 
SELECT department_id, department_name, manager_id FROM departments WHERE department_id = 999;

-- =====================================================================
-- 4. VOLVER A ESTABLECER LAS RESTRICCIONES
-- =====================================================================

-- Intentar volver a activar las restricciones (Aquí se generará el error ORA-02298)
ALTER TABLE employees ENABLE CONSTRAINT emp_dept_fk; 
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;

-- Limpieza: Borramos los datos falsos que insertamos
DELETE FROM employees WHERE employee_id = 7777; 
DELETE FROM departments WHERE department_id = 999; 

-- Volvemos a activar las restricciones (ahora funciona sin errores)
ALTER TABLE employees ENABLE CONSTRAINT emp_dept_fk; 
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk; 

-- Activamos el resto de restricciones que habíamos apagado
ALTER TABLE employees ENABLE CONSTRAINT emp_emp_id_pk; 
ALTER TABLE employees ENABLE CONSTRAINT emp_email_uk; 
ALTER TABLE employees ENABLE CONSTRAINT emp_job_fk; 
ALTER TABLE employees ENABLE CONSTRAINT emp_manager_fk; 
ALTER TABLE employees ENABLE CONSTRAINT emp_salary_min; 
ALTER TABLE departments ENABLE CONSTRAINT dept_id_pk;

-- =====================================================================
-- 5. DUPLICADO DE LA TABLA, TUPLAS, Y BLOQUE ANÓNIMO
-- =====================================================================

-- Crear un duplicado de la tabla departments
CREATE TABLE departments2 AS SELECT * FROM departments;

-- Insertar tres filas nuevas
INSERT INTO departments2 (department_id, department_name) VALUES (1000, 'Dept A'); 
INSERT INTO departments2 (department_id, department_name) VALUES (1001, 'Dept B'); 
INSERT INTO departments2 (department_id, department_name) VALUES (1002, 'Dept C'); 

-- Guardar los cambios
COMMIT;

-- Consultar la tabla (se puede ejecutar después de desconectar y reconectar)
SELECT * FROM departments2;

-- Crear un bloque anónimo (Recuerda habilitar la Salida de DBMS en SQL Developer)
SET SERVEROUTPUT ON;
BEGIN 
    -- Mensaje de inicio 
    DBMS_OUTPUT.PUT_LINE('--- Inicio de la transacción! ---'); 
    
    -- Operación DML sobre departments2 
    INSERT INTO departments2 (department_id, department_name) 
    VALUES (2000, 'Dept Transaccion'); 
    
    -- Mensaje de finalización 
    DBMS_OUTPUT.PUT_LINE('--- Fin de la transacción! (cambios pendientes) ---'); 
END; 
/

-- =====================================================================
-- 6. EJEMPLO PRÁCTICO DE ROLLBACK
-- =====================================================================

-- 1. Insertamos un departamento con un ID que no debería ir (ej. el 9999)
INSERT INTO departments2 (department_id, department_name) VALUES (9999, 'Departamento de Prueba'); 

-- 2. Consultamos para comprobar que el registro está ahí (temporalmente)
SELECT * FROM departments2 WHERE department_id = 9999; 

-- 3. Nos damos cuenta del error y deshacemos la transacción
ROLLBACK; 

-- 4. Volvemos a consultar. La fila ya no aparece porque el cambio se deshizo.
SELECT * FROM departments2 WHERE department_id = 9999;