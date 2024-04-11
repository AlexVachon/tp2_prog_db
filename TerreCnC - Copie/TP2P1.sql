SET SERVEROUTPUT ON;

// FONCTIONS
------------
--Q1_UTILISATEUR_EXISTE
--Une simple fonction qui valide si un utilisateur avec l�ID pass� en param�tre existe.
--La fonction retourne un bool�en.

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
--Cette fonction doit prendre en param�tre l�identifiant d�une annonce, une date de d�but et une
--date de fin de s�jour.
--Elle devra valider si l�annonce est disponible ou non pour la plage horaire pass�e en param�tre
--et retourner un bool�en.

CREATE OR REPLACE FUNCTION ANNONCE_DISPONIBLE_FCT(
i_annonce in cnc.annonces.annonceid%type, 
i_date_debut in cnc.reservations.datedebut%type, 
i_date_fin in cnc.reservations.datefin%type)
RETURN BOOLEAN is rec_count INT;
BEGIN
    IF(i_date_debut > i_date_fin) THEN
        RAISE_APPLICATION_ERROR(-20001, 'La date de fin ne peut pas �tre ant�rieure � la date de d�but.');
    END IF;
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
--Cette fonction prend en param�tre l�id d�une annonce, une date de d�but, une date de fin ainsi
--qu�un nombre de personnes.
--Elle devra calculer le montant total d�une �ventuelle r�servation en respectant les r�gles
--suivantes :
---     -Le montant total est calcul� selon le nombre de nuits r�serv�es.
---     -Des frais de nettoyage s�appliquent � un taux de 20$ par personne par nuit, pour les
--          deux premi�res nuits.
---     -Pour chaque nuit suppl�mentaire, ces frais de nettoyage diminuent de 2$ par personne
--          par nuit, jusqu�� un minimum de 5$.

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
        RAISE_APPLICATION_ERROR(-20001, 'La date de fin ne peut pas �tre ant�rieure � la date de d�but.');
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
--Cette fonction renvoie l�ensemble des messages �chang�s entre deux utilisateurs dans un
--tableau.
--Les messages doivent-�tre stock�s en ordre chronologique dans un tableau de type VARRAY.

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
--Cette fonction doit supprimer l�annonce dont l�ID est pass� en param�tre.
--Vous devez �galement supprimer les r�servations, les commentaires et les photos associ�es �
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
    
    DBMS_OUTPUT.PUT_LINE('Annonce supprim�e avec succ�s.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la suppression de l''annonce: ' || SQLERRM);
END SUPPRIMER_ANNONCE_PRC;

--Q6_RESERVER
--Cette proc�dure prend en param�tre l�id d�une annonce, une date de d�but, une date de fin
--ainsi qu�un nombre de personnes.
--Elle utilise la fonction Q2_ANNONCE_EST_DISPONIBLE afin de valider que l�endroit est
--disponible selon les dates fournies.
--Si aucune autre r�servation n�entre en conflit avec les dates demand�es, elle cr�e une
--r�servation dans la base de donn�es.
--Le montant total de la r�servation doit-�tre calcul� via la fonction Q3_CALCULER_TOTAL.
--Le statut de la r�servation doit-�tre �En attente�.


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
        
        INSERT INTO cnc.reservations (reservationid, utilisateurid, annonceid, datedebut, datefin, statut, montanttotal) 
        VALUES ((select max(reservationid) from cnc.reservations) + 1, null, i_annonceid, i_date_debut, i_date_fin, 'en attente', rec_prix);
        
        DBMS_OUTPUT.PUT_LINE('R�servation enregistr�e!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Les dates rentrent en conflit avec une autre r�servation.');
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur lors de la r�servation: ' || SQLERRM);
END RESERVER_PRC;

--Q7_AFFICHER_CONVERSATION
--Cette proc�dure utilise la fonction Q4_OBTENIR_MESSAGE_HISTORIQUE afin d�afficher les
--messages �chang�s entre deux utilisateurs dans la console.
--On doit pouvoir visualiser les messages �chang�s en ordre avec la date de leur envoi comme
--dans un syst�me de messagerie.
--Si aucun message n'est trouv� entre les deux utilisateurs, la proc�dure affiche un message
--indiquant qu'aucune conversation n'a �t� trouv�e.
CREATE OR REPLACE PROCEDURE AFFICHER_CONVERSATION_PRC(
    p_user1id IN NUMBER,
    p_user2id IN NUMBER
) IS
    v_Messages t_historique_message_varray;
BEGIN
    v_Messages := OBTENIR_MESSAGE_HISTORIQUE_FCT(p_user1id, p_user2id);
    IF v_Messages.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucune conversation trouv�e entre les utilisateurs sp�cifi�s.');
    ELSE
    DBMS_OUTPUT.PUT_LINE('Messages �chang�s entre les utilisateurs ' || p_user1id || ' et ' || p_user2id || ':');
        FOR i IN 1..v_Messages.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Message ' || i || ' envoy� par ' || v_Messages(i).ExpediteurUtilisateurID || ':');
            DBMS_OUTPUT.PUT_LINE('  Contenu: ' || v_Messages(i).Contenu);
            DBMS_OUTPUT.PUT_LINE('  Date: ' || TO_CHAR(v_Messages(i).DateEnvoi, 'DD-MM-YYYY HH24:MI:SS'));
            DBMS_OUTPUT.PUT_LINE('---------------------------------------');
        END LOOP;
    END IF;
END AFFICHER_CONVERSATION_PRC;

--Q8_REVENUS_PAR_LOCALISATION
--Cette proc�dure stocke les revenus g�n�r�s dans chaque localisation dans un tableau
--associatif (dictionnaire). Elle it�re ensuite ce dictionnaire et affiche son contenu.
--Exemple :
--Qu�bec : 10 000$
--Trois-Rivi�res : 8500$

CREATE OR REPLACE PROCEDURE REVENUS_PAR_LOCALISATION_PRC (p_tableau OUT t_tableau_revenus) IS
TYPE t_tableau_revenus IS TABLE OF NUMBER INDEX BY VARCHAR2(200);
BEGIN
    p_tableau := t_tableau_revenus();
    FOR i IN (
        SELECT a.LOCALISATION, SUM(r.MONTANTTOTAL) AS TOTAL 
        FROM ANNONCES a JOIN RESERVATIONS r ON r.ANNONCEID = a.ANNONCEID 
        WHERE r.STATUT = 'confirm�e' 
        GROUP BY a.Localisation)
    LOOP
        p_tableau(rec.Localisation) := rec.Total;
        DBMS_OUTPUT.PUT_LINE('rec.Localisation' || ' : ' || rec.Total || '$');
    END LOOP;
END REVENUS_PAR_LOCALISATION_PRC;

--Q9_RESERVATION_PAR_USAGER_PAR_ANNONCE
--Cette proc�dure doit g�n�rer dans la console un rapport qui affiche, pour chaque annonce, la
--liste des utilisateurs ayant r�serv� cette annonce ainsi que les informations de leurs
--r�servations.

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
                -- Bloc pour les informations de la r�servation
                DBMS_OUTPUT.PUT_LINE(
                    '       Reservation ID: ' || r.reservationid ||
                    ', Date d�but: ' || TO_CHAR(r.datedebut, 'DD-MM-YYYY') ||
                    ', Date fin: ' || TO_CHAR(r.datefin, 'DD-MM-YYYY')
                );
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
    END LOOP;
END RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC;


exec RESERVATION_PAR_USAGER_PAR_ANNONCE_PRC;


-- Sp�cification du package
CREATE OR REPLACE PACKAGE TRAITEMENTS_CNC_PKG AS
    -- Fonction pour v�rifier si un utilisateur existe
    FUNCTION utilisateur_existe(
        i_num_user IN cnc.utilisateurs.utilisateurid%TYPE
    ) RETURN BOOLEAN;
    
    -- Fonction pour v�rifier si une annonce est disponible
    FUNCTION annonce_disponible(
        i_annonce IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN cnc.reservations.datedebut%TYPE, 
        i_date_fin IN cnc.reservations.datefin%TYPE
    ) RETURN BOOLEAN;
    
    -- Fonction pour calculer le montant total d'une r�servation
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
    
    -- Proc�dure pour supprimer une annonce avec ses r�servations associ�es
    PROCEDURE supprimer_annonce(
        in_annonceid IN cnc.annonces.annonceid%TYPE
    );
    
    -- Proc�dure pour effectuer une r�servation
    PROCEDURE reserver(
        i_annonceid IN cnc.annonces.annonceid%TYPE, 
        i_date_debut IN DATE, 
        i_date_fin IN DATE,
        i_nombre IN INT
    );
    
    -- Proc�dure pour afficher l'historique des messages entre deux utilisateurs
    PROCEDURE afficher_conversation(
        p_user1id IN NUMBER,
        p_user2id IN NUMBER
    );
    
    -- Proc�dure pour stocker les revenus g�n�r�s par localisation
--    PROCEDURE revenus_par_localisation(
--        p_tableau OUT t_tableau_revenus
--    );
    
    -- Proc�dure pour afficher les r�servations par utilisateur et par annonce
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