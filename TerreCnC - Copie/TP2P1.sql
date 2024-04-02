set serverout on;

// FONCTIONS
------------
--Q1_UTILISATEUR_EXISTE
--Une simple fonction qui valide si un utilisateur avec l�ID pass� en param�tre existe.
--La fonction retourne un bool�en.

CREATE OR REPLACE FUNCTION UTILISATEUR_EXISTE_FCT(i_num_user in cnc.utilisateurs.id%type) 
RETURN BOOLEAN is rec_user cnc.utilisateurs%rowtype;

BEGIN
    select 
        u.UTILISATEURID ,
        u.NOM ,
        u.PRENOM ,
        u.EMAIL ,
        u.MOTDEPASSE 
    into rec_user from cnc.utilisateurs u where u.id = i_num_user;
    
    IF rec_user is null then
        return FALSE;
    ELSE
        return TRUE;
    END IF;
END UTILISATEUR_EXISTE_FCT;

--Q2_ANNONCE_EST_DISPONIBLE
--Cette fonction doit prendre en param�tre l�identifiant d�une annonce, une date de d�but et une
--date de fin de s�jour.
--Elle devra valider si l�annonce est disponible ou non pour la plage horaire pass�e en param�tre
--et retourner un bool�en.

CREATE OR REPLACE FUNCTION ANNONCE_DISPONIBLE_FCT(i_annonce in cnc.annonces.id%type, i_date_debut in cnc.reservations.date%type, i_date_fin in cnc.reservations.date%type)
RETURN BOOLEAN is rec_user cnc.annonces%rowtype;

BEGIN
    select
        a.ANNONCEID,
        a.TITRE,
        a.DESCRIPTION,
        r.RESERVATIONID,
        r.ANNONCEID,
        r.DATEDEBUT,
        r.DATEFIN,
        r.STATUT
    into rec_user from cnc.annonces a inner join cnc.reservations r on a.ANNONCEID = r.ANNONCEID
    where a.ANNONCEID = i_annonce
    and i_date_debut not between r.DATEDEBUT and r.DATEFIN
    and i_date_fin not between r.DATEDEBUT and r.DATEFIN;
    
    IF rec_user is null then
        return TRUE;
    ELSE
        return FALSE;
    END IF;
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



--Q4_OBTENIR_MESSAGE_HISTORIQUE
--Cette fonction renvoie l�ensemble des messages �chang�s entre deux utilisateurs dans un
--tableau.
--Les messages doivent-�tre stock�s en ordre chronologique dans un tableau de type VARRAY.





// PROCEDURE STOCKER

--Q5_SUPPRIMER_ANNONCE
--Cette fonction doit supprimer l�annonce dont l�ID est pass� en param�tre.
--Vous devez �galement supprimer les r�servations, les commentaires et les photos associ�es �
--cette annonce.




--Q6_RESERVER
--Cette proc�dure prend en param�tre l�id d�une annonce, une date de d�but, une date de fin
--ainsi qu�un nombre de personnes.
--Elle utilise la fonction Q2_ANNONCE_EST_DISPONIBLE afin de valider que l�endroit est
--disponible selon les dates fournies.
--Si aucune autre r�servation n�entre en conflit avec les dates demand�es, elle cr�e une
--r�servation dans la base de donn�es.
--Le montant total de la r�servation doit-�tre calcul� via la fonction Q3_CALCULER_TOTAL.
--Le statut de la r�servation doit-�tre �En attente�.



--Q7_AFFICHER_CONVERSATION
--Cette proc�dure utilise la fonction Q4_OBTENIR_MESSAGE_HISTORIQUE afin d�afficher les
--messages �chang�s entre deux utilisateurs dans la console.
--On doit pouvoir visualiser les messages �chang�s en ordre avec la date de leur envoi comme
--dans un syst�me de messagerie.
--Si aucun message n'est trouv� entre les deux utilisateurs, la proc�dure affiche un message
--indiquant qu'aucune conversation n'a �t� trouv�e.




--Q8_REVENUS_PAR_LOCALISATION
--Cette proc�dure stocke les revenus g�n�r�s dans chaque localisation dans un tableau
--associatif (dictionnaire). Elle it�re ensuite ce dictionnaire et affiche son contenu.
--Exemple :
--Qu�bec : 10 000$
--Trois-Rivi�res : 8500$



--Q9_RESERVATION_PAR_USAGER_PAR_ANNONCE
--Cette proc�dure doit g�n�rer dans la console un rapport qui affiche, pour chaque annonce, la
--liste des utilisateurs ayant r�serv� cette annonce ainsi que les informations de leurs
--r�servations.





