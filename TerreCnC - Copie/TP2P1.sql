set serverout on;

// FONCTIONS
------------
--Q1_UTILISATEUR_EXISTE
--Une simple fonction qui valide si un utilisateur avec l’ID passé en paramètre existe.
--La fonction retourne un booléen.

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
--Cette fonction doit prendre en paramètre l’identifiant d’une annonce, une date de début et une
--date de fin de séjour.
--Elle devra valider si l’annonce est disponible ou non pour la plage horaire passée en paramètre
--et retourner un booléen.

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
--Cette fonction prend en paramètre l’id d’une annonce, une date de début, une date de fin ainsi
--qu’un nombre de personnes.
--Elle devra calculer le montant total d’une éventuelle réservation en respectant les règles
--suivantes :
---     -Le montant total est calculé selon le nombre de nuits réservées.
---     -Des frais de nettoyage s’appliquent à un taux de 20$ par personne par nuit, pour les
--          deux premières nuits.
---     -Pour chaque nuit supplémentaire, ces frais de nettoyage diminuent de 2$ par personne
--          par nuit, jusqu’à un minimum de 5$.



--Q4_OBTENIR_MESSAGE_HISTORIQUE
--Cette fonction renvoie l’ensemble des messages échangés entre deux utilisateurs dans un
--tableau.
--Les messages doivent-être stockés en ordre chronologique dans un tableau de type VARRAY.





// PROCEDURE STOCKER

--Q5_SUPPRIMER_ANNONCE
--Cette fonction doit supprimer l’annonce dont l’ID est passé en paramètre.
--Vous devez également supprimer les réservations, les commentaires et les photos associées à
--cette annonce.




--Q6_RESERVER
--Cette procédure prend en paramètre l’id d’une annonce, une date de début, une date de fin
--ainsi qu’un nombre de personnes.
--Elle utilise la fonction Q2_ANNONCE_EST_DISPONIBLE afin de valider que l’endroit est
--disponible selon les dates fournies.
--Si aucune autre réservation n’entre en conflit avec les dates demandées, elle crée une
--réservation dans la base de données.
--Le montant total de la réservation doit-être calculé via la fonction Q3_CALCULER_TOTAL.
--Le statut de la réservation doit-être ‘En attente’.



--Q7_AFFICHER_CONVERSATION
--Cette procédure utilise la fonction Q4_OBTENIR_MESSAGE_HISTORIQUE afin d’afficher les
--messages échangés entre deux utilisateurs dans la console.
--On doit pouvoir visualiser les messages échangés en ordre avec la date de leur envoi comme
--dans un système de messagerie.
--Si aucun message n'est trouvé entre les deux utilisateurs, la procédure affiche un message
--indiquant qu'aucune conversation n'a été trouvée.




--Q8_REVENUS_PAR_LOCALISATION
--Cette procédure stocke les revenus générés dans chaque localisation dans un tableau
--associatif (dictionnaire). Elle itère ensuite ce dictionnaire et affiche son contenu.
--Exemple :
--Québec : 10 000$
--Trois-Rivières : 8500$



--Q9_RESERVATION_PAR_USAGER_PAR_ANNONCE
--Cette procédure doit générer dans la console un rapport qui affiche, pour chaque annonce, la
--liste des utilisateurs ayant réservé cette annonce ainsi que les informations de leurs
--réservations.





