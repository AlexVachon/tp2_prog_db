SET SERVEROUTPUT ON;

// FONCTIONS
------------
--Q1_UTILISATEUR_EXISTE
--Une simple fonction qui valide si un utilisateur avec l’ID passé en paramètre existe.
--La fonction retourne un booléen.

CREATE OR REPLACE FUNCTION UTILISATEUR_EXISTE_FCT(i_num_user IN cnc.utilisateurs.utilisateurid%TYPE) 
RETURN BOOLEAN IS 
    rec_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO rec_count 
    FROM cnc.utilisateurs u 
    WHERE u.utilisateurid = i_num_user;

    RETURN rec_count > 0;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END UTILISATEUR_EXISTE_FCT;

--Q2_ANNONCE_EST_DISPONIBLE
--Cette fonction doit prendre en paramètre l’identifiant d’une annonce, une date de début et une
--date de fin de séjour.
--Elle devra valider si l’annonce est disponible ou non pour la plage horaire passée en paramètre
--et retourner un booléen.

CREATE OR REPLACE FUNCTION ANNONCE_DISPONIBLE_FCT(
i_annonce in cnc.annonces.annonceid%type, 
i_date_debut in cnc.reservations.datedebut%type, 
i_date_fin in cnc.reservations.datefin%type)
RETURN BOOLEAN is rec_count INT;
BEGIN
    select count(
        a.ANNONCEID
        )
    into rec_count from cnc.annonces a inner join cnc.reservations r on a.ANNONCEID = r.ANNONCEID
    where a.ANNONCEID = i_annonce
    and (i_date_debut between r.DATEDEBUT and r.DATEFIN
        or i_date_fin between r.DATEDEBUT and r.DATEFIN);
    return rec_count = 0;
        
END ANNONCE_DISPONIBLE_FCT;

--Q3_CALCULER_TOTAL
--Cette fonction prend en paramètre l’id d’une annonce, une date de début, une date de fin ainsi
--qu’un nombre de personnes.
--Elle devra calculer le montant total d’une éventuelle réservation en respectant les règles
--suivantes :
---     -Le montant total est calculé selon le nombre de nuits réservées.
---     -Des frais de nettoyage s’appliquent à un taux de 20$ par personne par nuit, pour les
--          deux premières nuits.
---     -Pour chaque nuit supplémentaire, ces frais de nettoyage diminuent de 2$ par personne
--          par nuit, jusqu’à un minimum de 5$.

CREATE OR REPLACE FUNCTION CALCULER_TOTAL_FCT (
    i_id_annonce IN cnc.annonces.annonceid%TYPE,
    i_date_debut IN DATE,
    i_date_fin IN DATE,
    i_nombre IN INT
) RETURN NUMBER IS
    prix_total NUMBER := 0;
    prix_par_nuit cnc.annonces.prixparnuit%TYPE;
    interval_jour NUMBER;
    frais_nettoyage NUMBER := 20;
    i NUMBER;
BEGIN
    SELECT a.prixparnuit INTO prix_par_nuit FROM cnc.annonces a WHERE a.annonceid = i_id_annonce;

    interval_jour := i_date_fin - i_date_debut;
    
    if interval_jour < 0 then
        RAISE_APPLICATION_ERROR(-20001, 'La date de fin ne peut pas être antérieure à la date de début.');
    end if;

    FOR i IN 1..interval_jour LOOP
        prix_total := prix_total + prix_par_nuit + (frais_nettoyage * i_nombre);

        IF i > 2 THEN
            frais_nettoyage := frais_nettoyage - (2 * i_nombre);
            IF frais_nettoyage < 5 THEN
                frais_nettoyage := 5;
            END IF;
        END IF;
    END LOOP;
    
    RETURN prix_total;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(sqlerrm);
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
        RETURN 0;
END CALCULER_TOTAL_FCT;

--Q4_OBTENIR_MESSAGE_HISTORIQUE
--Cette fonction renvoie l’ensemble des messages échangés entre deux utilisateurs dans un
--tableau.
--Les messages doivent-être stockés en ordre chronologique dans un tableau de type VARRAY.

CREATE OR REPLACE TYPE t_message_varray AS OBJECT(
    MessageID NUMBER,
    ExpediteurUtilisateurID NUMBER,
    DestinataireUtilisateurID NUMBER,
    Contenu VARCHAR2(1000),
    DateEnvoi DATE
);

CREATE OR REPLACE TYPE t_historique_message_varray AS VARRAY(1000) OF t_message_varray;

CREATE OR REPLACE FUNCTION OBTENIR_MESSAGE_HISTORIQUE_FCT(
i_user1 in cnc.utilisateurs.utilisateurid%type, 
i_user2 in cnc.utilisateurs.utilisateurid%type)
RETURN t_historique_message_varray IS v_Messages t_historique_message_varray := t_historique_message_varray();
BEGIN
    FOR msg IN(
        SELECT 
            MESSAGEID ,
            EXPEDITEURUTILISATEURID ,
            DESTINATAIREUTILISATEURID ,
            CONTENU ,
            DATEENVOI
        FROM messages 
        WHERE (expediteurutilisateurid = i_user1 AND destinataireutilisateurid = i_user2) 
            OR (expediteurutilisateurid = i_user2 AND destinataireutilisateurid = i_user1)
        ORDER BY dateenvoi)
    LOOP
        v_Messages.EXTEND;
        v_Messages(v_Messages.LAST) := t_message_varray(
            msg.MessageID,
            msg.ExpediteurUtilisateurID,
            msg.DestinataireUtilisateurID,
            msg.Contenu,
            msg.DateEnvoi);
    END LOOP;
    RETURN v_Messages;
END OBTENIR_MESSAGE_HISTORIQUE_FCT;

// PROCEDURE STOCKER

--Q5_SUPPRIMER_ANNONCE
--Cette fonction doit supprimer l’annonce dont l’ID est passé en paramètre.
--Vous devez également supprimer les réservations, les commentaires et les photos associées à
--cette annonce.

CREATE OR REPLACE PROCEDURE SUPPRIMER_ANNONCE_PRC(in_annonceid IN cnc.annonces.annonceid%TYPE)
IS
BEGIN
    DELETE FROM cnc.reservations r WHERE r.annonceid = in_annonceid;
    
    DELETE FROM cnc.commentaires c WHERE c.annonceid = in_annonceid;
    
    DELETE FROM cnc.utilisateurs_annonces u WHERE u.annonceid = in_annonceid;
    
    DELETE FROM cnc.photos p where p.annonceid = in_annonceid;
    
    DELETE FROM cnc.annonces a WHERE a.annonceid = in_annonceid; 
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Annonce supprimée avec succès.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la suppression de l''annonce: ' || SQLERRM);
END SUPPRIMER_ANNONCE_PRC;

--Q6_RESERVER
--Cette procédure prend en paramètre l’id d’une annonce, une date de début, une date de fin
--ainsi qu’un nombre de personnes.
--Elle utilise la fonction Q2_ANNONCE_EST_DISPONIBLE afin de valider que l’endroit est
--disponible selon les dates fournies.
--Si aucune autre réservation n’entre en conflit avec les dates demandées, elle crée une
--réservation dans la base de données.
--Le montant total de la réservation doit-être calculé via la fonction Q3_CALCULER_TOTAL.
--Le statut de la réservation doit-être ‘En attente’.


CREATE OR REPLACE PROCEDURE RESERVER_PRC(
    i_annonceid IN cnc.annonces.annonceid%TYPE, 
    i_date_debut IN DATE, 
    i_date_fin IN DATE,
    i_nombre IN INT
)
IS
    rec_disponible BOOLEAN;
    rec_prix NUMBER;
BEGIN
    rec_disponible := ANNONCE_DISPONIBLE_FCT(i_annonceid, i_date_debut, i_date_fin);
    
    IF rec_disponible THEN
        DBMS_OUTPUT.PUT_LINE('Aucune reservation en conflit');
        rec_prix := CALCULER_TOTAL_FCT(i_annonceid, i_date_debut, i_date_fin, i_nombre);
        
        INSERT INTO cnc.reservations (annonceid, datedebut, datefin, statut, montanttotal) 
        VALUES (i_annonceid, i_date_debut, i_date_fin, 'en attente', rec_prix);
        
        DBMS_OUTPUT.PUT_LINE('Réservation enregistrée!');

    ELSE
        DBMS_OUTPUT.PUT_LINE('Les dates rentrent en conflit avec une autre réservation.');

    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la réservation: ' || SQLERRM);
END RESERVER_PRC;


BEGIN
    RESERVER_PRC(
        1 , TO_DATE('2024-04-06', 'YYYY-MM-DD'), TO_DATE('2024-04-08', 'YYYY-MM-DD'), 2
    );
END;

select * from cnc.reservations r where r.datedebut =  TO_DATE('2024-04-01', 'YYYY-MM-DD') and r.datefin = TO_DATE('2024-04-02', 'YYYY-MM-DD') and r.annonceid = 1;

select * from cnc.reservations;
select * from cnc.annonces;

--Q7_AFFICHER_CONVERSATION
--Cette procédure utilise la fonction Q4_OBTENIR_MESSAGE_HISTORIQUE afin d’afficher les
--messages échangés entre deux utilisateurs dans la console.
--On doit pouvoir visualiser les messages échangés en ordre avec la date de leur envoi comme
--dans un système de messagerie.
--Si aucun message n'est trouvé entre les deux utilisateurs, la procédure affiche un message
--indiquant qu'aucune conversation n'a été trouvée.
CREATE OR REPLACE PROCEDURE AFFICHER_CONVERSATION_PRC(
    p_user1id IN NUMBER,
    p_user2id IN NUMBER
) IS
    v_Messages t_historique_message_varray;
BEGIN
    v_Messages := OBTENIR_MESSAGE_HISTORIQUE_FCT(p_user1id, p_user2id);
    IF v_Messages.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucune conversation trouvée entre les utilisateurs spécifiés.');
    ELSE
    DBMS_OUTPUT.PUT_LINE('Messages échangés entre les utilisateurs ' || p_user1id || ' et ' || p_user2id || ':');
        FOR i IN 1..v_Messages.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Message ' || i || ' envoyé par ' || v_Messages(i).ExpediteurUtilisateurID || ':');
            DBMS_OUTPUT.PUT_LINE('  Contenu: ' || v_Messages(i).Contenu);
            DBMS_OUTPUT.PUT_LINE('  Date: ' || TO_CHAR(v_Messages(i).DateEnvoi, 'DD-MM-YYYY HH24:MI:SS'));
            DBMS_OUTPUT.PUT_LINE('---------------------------------------');
        END LOOP;
    END IF;
END AFFICHER_CONVERSATION_PRC;

--Q8_REVENUS_PAR_LOCALISATION
--Cette procédure stocke les revenus générés dans chaque localisation dans un tableau
--associatif (dictionnaire). Elle itère ensuite ce dictionnaire et affiche son contenu.
--Exemple :
--Québec : 10 000$
--Trois-Rivières : 8500$

CREATE TYPE t_tableau_revenus IS TABLE OF NUMBER INDEX BY VARCHAR2(200);

CREATE OR REPLACE PROCEDURE REVENUS_PAR_LOCALISATION_PRC (p_tableau OUT t_tableau_revenus) IS
BEGIN
    p_tableau := t_tableau_revenus();
    FOR i IN (
        SELECT a.LOCALISATION, SUM(r.MONTANTTOTAL) AS TOTAL 
        FROM ANNONCES a JOIN RESERVATIONS r ON r.ANNONCEID = a.ANNONCEID 
        WHERE r.STATUT = 'confirmée' 
        GROUP BY a.Localisation)
    LOOP
        p_tableau(rec.Localisation) := rec.Total;
        DBMS_OUTPUT.PUT_LINE('Localisation : ' || rec.Localisation || ', Total Revenus : ' || rec.Total);
    END LOOP;
    
END REVENUS_PAR_LOCALISATION_PRC;

--Q9_RESERVATION_PAR_USAGER_PAR_ANNONCE
--Cette procédure doit générer dans la console un rapport qui affiche, pour chaque annonce, la
--liste des utilisateurs ayant réservé cette annonce ainsi que les informations de leurs
--réservations.

CREATE OR REPLACE PROCEDURE RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC
IS
BEGIN
    FOR a IN (SELECT DISTINCT a.annonceid, a.titre
              FROM cnc.annonces a
              JOIN cnc.reservations r ON a.annonceid = r.annonceid
              ORDER BY a.annonceid)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Annonce ID: ' || a.annonceid || ', Titre: ' || a.titre);
         DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
         DBMS_OUTPUT.PUT_LINE('');
        
        FOR u IN (SELECT DISTINCT u.utilisateurid, u.nom, u.prenom, u.email
                  FROM cnc.reservations r
                  JOIN cnc.utilisateurs u ON r.utilisateurid = u.utilisateurid
                  WHERE r.annonceid = a.annonceid
                  ORDER BY u.utilisateurid)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                ' - Utilisateur: ' || u.nom || ' ' || u.prenom ||
                ', Email: ' || u.email
            );
            DBMS_OUTPUT.PUT_LINE('');
            
            FOR r IN (SELECT r.*
                      FROM cnc.reservations r
                      WHERE r.annonceid = a.annonceid
                        AND r.utilisateurid = u.utilisateurid
                      ORDER BY r.reservationid)
            LOOP
                -- Bloc pour les informations de la réservation
                DBMS_OUTPUT.PUT_LINE(
                    '       Reservation ID: ' || r.reservationid ||
                    ', Date début: ' || TO_CHAR(r.datedebut, 'DD-MM-YYYY') ||
                    ', Date fin: ' || TO_CHAR(r.datefin, 'DD-MM-YYYY')
                );
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
    END LOOP;
END RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC;


exec RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC;


-- Spécification du package
CREATE OR REPLACE PACKAGE TRAITEMENTS_CNC_PKG AS
    -- Fonction pour vérifier si un utilisateur existe
    FUNCTION utilisateur_existe(
        i_num_user IN cnc.utilisateurs.utilisateurid%TYPE
    ) RETURN BOOLEAN;
    
    -- Fonction pour vérifier si une annonce est disponible
    FUNCTION annonce_disponible(
        i_annonce IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN cnc.reservations.datedebut%TYPE, 
        i_date_fin IN cnc.reservations.datefin%TYPE
    ) RETURN BOOLEAN;
    
    -- Fonction pour calculer le montant total d'une réservation
    FUNCTION calculer_total(
        i_id_annonce IN cnc.annonces.annonceid%TYPE,
        i_date_debut IN DATE,
        i_date_fin IN DATE,
        i_nombre IN INT
    ) RETURN NUMBER;
    
    -- Fonction pour obtenir l'historique des messages entre deux utilisateurs
    FUNCTION obtenir_message_historique(
        i_user1 IN cnc.utilisateurs.utilisateurid%TYPE, 
        i_user2 IN cnc.utilisateurs.utilisateurid%TYPE
    ) RETURN t_historique_message_varray;
    
    -- Procédure pour supprimer une annonce avec ses réservations associées
    PROCEDURE supprimer_annonce(
        in_annonceid IN cnc.annonces.annonceid%TYPE
    );
    
    -- Procédure pour effectuer une réservation
    PROCEDURE reserver(
        i_annonceid IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN DATE, 
        i_date_fin IN DATE,
        i_nombre IN INT
    );
    
    -- Procédure pour afficher l'historique des messages entre deux utilisateurs
    PROCEDURE afficher_conversation(
        p_user1id IN NUMBER,
        p_user2id IN NUMBER
    );
    
    -- Procédure pour stocker les revenus générés par localisation
--    PROCEDURE revenus_par_localisation(
--        p_tableau OUT t_tableau_revenus
--    );
    
    -- Procédure pour afficher les réservations par utilisateur et par annonce
    PROCEDURE reservation_par_usager_par_annonce;
END TRAITEMENTS_CNC_PKG;


CREATE OR REPLACE PACKAGE BODY TRAITEMENTS_CNC_PKG AS
    FUNCTION utilisateur_existe(
        i_num_user IN cnc.utilisateurs.utilisateurid%TYPE
    ) RETURN BOOLEAN AS 
        resultat BOOLEAN;
    BEGIN
        resultat := UTILISATEUR_EXISTE_FCT(i_num_user);
        
        IF resultat THEN
            DBMS_OUTPUT.PUT_LINE('Utilisateur existe?: Oui');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Utilisateur existe?: Non');
        END IF;
        
        RETURN resultat;
    END utilisateur_existe;
    
    FUNCTION annonce_disponible(
        i_annonce IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN cnc.reservations.datedebut%TYPE, 
        i_date_fin IN cnc.reservations.datefin%TYPE
    ) RETURN BOOLEAN AS
        resultat BOOLEAN;
    BEGIN
        resultat := ANNONCE_DISPONIBLE_FCT(i_annonce, i_date_debut, i_date_fin);
        if resultat then
            dbms_output.put_line('disponible');
        else
            dbms_output.put_line('non disponible');
        end if;
        RETURN resultat;
    END annonce_disponible;
    
    FUNCTION calculer_total(
        i_id_annonce IN cnc.annonces.annonceid%TYPE,
        i_date_debut IN DATE,
        i_date_fin IN DATE,
        i_nombre IN INT
    ) RETURN NUMBER AS
        montant_total NUMBER;
    BEGIN
        montant_total := CALCULER_TOTAL_FCT(i_id_annonce, i_date_debut, i_date_fin, i_nombre);
        DBMS_OUTPUT.PUT_LINE('Montant total: ' || montant_total || '$');
        RETURN montant_total;
    END calculer_total;
    
    FUNCTION obtenir_message_historique(
        i_user1 IN cnc.utilisateurs.utilisateurid%TYPE, 
        i_user2 IN cnc.utilisateurs.utilisateurid%TYPE
    ) RETURN t_historique_message_varray AS 
        v_Messages t_historique_message_varray;
    BEGIN
        v_Messages := OBTENIR_MESSAGE_HISTORIQUE_FCT(i_user1, i_user2);
        FOR i IN 1..v_Messages.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Message ' || i || ':');
            DBMS_OUTPUT.PUT_LINE('   MessageID: ' || v_Messages(i).MessageID);
            DBMS_OUTPUT.PUT_LINE('   ExpediteurUtilisateurID: ' || v_Messages(i).ExpediteurUtilisateurID);
            DBMS_OUTPUT.PUT_LINE('   DestinataireUtilisateurID: ' || v_Messages(i).DestinataireUtilisateurID);
            DBMS_OUTPUT.PUT_LINE('   Contenu: ' || v_Messages(i).Contenu);
            DBMS_OUTPUT.PUT_LINE('   DateEnvoi: ' || TO_CHAR(v_Messages(i).DateEnvoi, 'DD-MM-YYYY HH24:MI:SS'));
            DBMS_OUTPUT.PUT_LINE('---------------------------------------');
        END LOOP;
        RETURN v_Messages;
    END obtenir_message_historique;
    
    PROCEDURE supprimer_annonce(
        in_annonceid IN cnc.annonces.annonceid%TYPE
    ) AS
    BEGIN
        SUPPRIMER_ANNONCE_PRC(in_annonceid);
    END supprimer_annonce;
    
    PROCEDURE reserver(
        i_annonceid IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN DATE, 
        i_date_fin IN DATE,
        i_nombre IN INT
    ) AS
    BEGIN
        RESERVER_PRC(i_annonceid, i_date_debut, i_date_fin, i_nombre);
    END reserver;
    
    PROCEDURE afficher_conversation(
        p_user1id IN NUMBER,
        p_user2id IN NUMBER
    ) AS
    BEGIN
        AFFICHER_CONVERSATION_PRC(p_user1id, p_user2id);
    END afficher_conversation;
    
--    PROCEDURE revenus_par_localisation(
--        p_tableau OUT t_tableau_revenus
--    ) AS
--    BEGIN
--        REVENUS_PAR_LOCALISATION_PRC(p_tableau);
--    END revenus_par_localisation;
    
    PROCEDURE reservation_par_usager_par_annonce AS
    BEGIN
        RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC();
    END reservation_par_usager_par_annonce;
END TRAITEMENTS_CNC_PKG;


// TESTS

--Q1
--declare
--    resultat BOOLEAN;
--begin
--    resultat := TRAITEMENTS_CNC_PKG.utilisateur_existe(1);
--end;

--Q2
--declare
--    resultat BOOLEAN;
--begin
--    resultat := TRAITEMENTS_CNC_PKG.annonce_disponible(1 , TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-05', 'YYYY-MM-DD'));
--    resultat := TRAITEMENTS_CNC_PKG.annonce_disponible(2 , TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-29', 'YYYY-MM-DD'));
--end;

--Q3
--DECLARE
--    montant_total NUMBER := 0;
--BEGIN
--    montant_total := TRAITEMENTS_CNC_PKG.calculer_total(1, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-04', 'YYYY-MM-DD'), 1);
--    montant_total := TRAITEMENTS_CNC_PKG.calculer_total(1, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-04', 'YYYY-MM-DD'), 2);
--    montant_total := TRAITEMENTS_CNC_PKG.calculer_total(1, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-04', 'YYYY-MM-DD'), 3);
--END;

--Q4
--declare
--    v_Message t_historique_message_varray;
--begin
--    v_Message := TRAITEMENTS_CNC_PKG.obtenir_message_historique(1, 2);
--end;

--Q5
--begin
--    TRAITEMENTS_CNC_PKG.supprimer_annonce(1);
--end;

--Q6
--begin
--    TRAITEMENTS_CNC_PKG.reserver(
--        5 , TO_DATE('2024-06-01', 'YYYY-MM-DD'), TO_DATE('2024-06-03', 'YYYY-MM-DD'), 2
--    );
--    TRAITEMENTS_CNC_PKG.reserver(
--        5 , TO_DATE('2024-06-06', 'YYYY-MM-DD'), TO_DATE('2024-06-08', 'YYYY-MM-DD'), 2
--    );
--
--end;
--

--Q7
--begin
--    TRAITEMENTS_CNC_PKG.afficher_conversation(1, 2);
--end;

--Q8


--Q9
--begin
--    TRAITEMENTS_CNC_PKG.reservation_par_usager_par_annonce();
--end;