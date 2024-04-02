-- Utilisateur générique pour l'application
CREATE USER cnc IDENTIFIED BY cnc;
GRANT CONNECT, RESOURCE, DBA TO cnc;
