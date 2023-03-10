ALTER TABLE dbo.INVENTAIRE_STOCK_LIGNE ADD
	TAILLE_ID numeric(18, 0) NULL,
	NOM_TAILLE nvarchar(50) NULL,
	COULEUR_ID numeric(18, 0) NULL,
	NOM_COULEUR nvarchar(50) NULL
GO

--------------------------------------------------------------------------------

update CONTROLE set LISTE_DDL='select  ''PARTIEL'',''GLOBAL''',VALEUR_DEFAUT_CTRL='PARTIEL',
MODIFIABLE_INSERT_CTRL=0
where PAGE_ID=24 and ID_CTRL=440
GO

------------------------------------------------------------------------

IF OBJECT_ID('VUE_STOCK_DEPOT_PROPRIETE', 'V') IS NOT NULL  
    DROP VIEW VUE_STOCK_DEPOT_PROPRIETE;  
GO
CREATE VIEW [dbo].[VUE_STOCK_DEPOT_PROPRIETE] as 
With CTE as (
select ROW_NUMBER() over (partition by A.SOCIETE_ID order by (select 1)) as ID_SD,
A.ID_ARTICLE,
A.CODE_ARTICLE,
A.LIBELLE_ARTICLE,
A.NOM_UNITE_ARTICLE,
D.ID_DEPOT,
D.NOM_DEPOT,
A.SOCIETE_ID,
A.TAILLE_ID,
A.NOM_TAILLE,
A.COULEUR_ID,
A.NOM_COULEUR
from VUE_ARTICLE_PROPRIETE A
JOIN DEPOT D on A.SOCIETE_ID=D.SOCIETE_ID where A.GESTION_STOCK=1)

select 
C.ID_SD,
C.ID_ARTICLE,
C.CODE_ARTICLE,
C.LIBELLE_ARTICLE,
C.NOM_UNITE_ARTICLE,
C.ID_DEPOT,
C.NOM_DEPOT,
CASE WHEN C.TAILLE_ID is NULL and C.COULEUR_ID is NULL 
THEN ISNULL(S.QUANTITE_STOCK_SD,0)
ELSE ISNULL(P.QUANTITE_STOCK_PROPRIETE,0)
END as QUANTITE,
C.SOCIETE_ID as SOCIETE_ID,
C.TAILLE_ID,
C.NOM_TAILLE,
C.COULEUR_ID,
C.NOM_COULEUR
from CTE C 
Left join STOCK_DEPOT S on C.ID_ARTICLE=S.ARTICLE_SD_ID and C.ID_DEPOT=S.DEPOT_SD_ID
Left join STOCK_PROPRIETE P on P.ARTICLE_PROPRIETE_ID=C.ID_ARTICLE and P.TAILLE_PROPRIETE_ID=C.TAILLE_ID and P.COULEUR_PROPRIETE_ID=C.COULEUR_ID and P.DEPOT_PROPRIETE_ID=C.ID_DEPOT
GO

-----------------------------------------------------------------------
IF OBJECT_ID('INVENTAIRE_STOCK_I') IS NOT NULL  
    DROP TRIGGER INVENTAIRE_STOCK_I;  
GO
CREATE TRIGGER  [dbo].[INVENTAIRE_STOCK_I]
   ON  [dbo].[INVENTAIRE_STOCK]
   AFTER INSERT
AS 
BEGIN

declare @ID numeric(18,0)
declare @TYPE_DOCUMENT int
declare @TYPE varchar(50)
declare @ID_SOCIETE numeric(18,0)
declare @ID_DEPOT numeric(18,0)
declare @sql nvarchar(4000)

set @TYPE_DOCUMENT=31

select @ID=ID_IS,@TYPE=TYPE_IS,@ID_SOCIETE=SOCIETE_ID,@ID_DEPOT=DEPOT_IS_ID from inserted

BEGIN TRANSACTION

BEGIN TRY

EXEC PRC_INSERER_DOCUMENT_2 @TYPE_DOCUMENT,@ID

if @TYPE='GLOBAL'
	Begin
		set @sql='Insert [INVENTAIRE_STOCK_LIGNE] ([IS_ID],[ARTICLE_IS_L_ID],[ARTICLE_CODE_IS_L],[LIBELLE_ARTICLE_IS_L],
		[QUANTITE_THEORIQUE_IS_L],[QUANTITE_REEL_IS_L],
		TAILLE_ID,NOM_TAILLE,COULEUR_ID,NOM_COULEUR
		)
		select '+CAST(@ID as varchar(50))+',ID_ARTICLE,CODE_ARTICLE,LIBELLE_ARTICLE,QUANTITE,0,TAILLE_ID,NOM_TAILLE,COULEUR_ID,NOM_COULEUR from VUE_STOCK_DEPOT_PROPRIETE
		where SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+' and ID_DEPOT='+CAST(@ID_DEPOT as varchar(50))
		execute sp_executesql @sql
	End
else
	Begin
		set @sql='Insert [INVENTAIRE_STOCK_LIGNE] ([IS_ID],[ARTICLE_IS_L_ID],[ARTICLE_CODE_IS_L],[LIBELLE_ARTICLE_IS_L],
		[QUANTITE_THEORIQUE_IS_L],[QUANTITE_REEL_IS_L],
		TAILLE_ID,NOM_TAILLE,COULEUR_ID,NOM_COULEUR)
		select '+CAST(@ID as varchar(50))+',ID_ARTICLE,CODE_ARTICLE,LIBELLE_ARTICLE,QUANTITE,QUANTITE,TAILLE_ID,NOM_TAILLE,COULEUR_ID,NOM_COULEUR from VUE_STOCK_DEPOT_PROPRIETE
		where SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+' and ID_DEPOT='+CAST(@ID_DEPOT as varchar(50))
		execute sp_executesql @sql
	End
END TRY
BEGIN CATCH  
	ROLLBACK TRANSACTION
	insert SQL_ERREUR (QUERY) values (@SQL)
	select -99,ERROR_NUMBER() 
	RETURN
END CATCH; 
COMMIT TRANSACTION

END

GO

--------------------------------------------------------------------------

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+4
where GRID_ID=92 and ORDRE_COLONNE>=5

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1801,'92','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','1','5','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1802,'92','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','1','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1803,'92','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','1','0','0','0','0','0','1','0','7','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1804,'92','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','1','0','0','0','0','0','1','0','8','NUMERIC','L')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=92
GO
----------------------------------------------------------------
IF OBJECT_ID('VUE_INVENTAIRE_STOCK_LIGNE') IS NOT NULL  
    DROP VIEW VUE_INVENTAIRE_STOCK_LIGNE;  
GO

CREATE VIEW [dbo].[VUE_INVENTAIRE_STOCK_LIGNE]
AS
SELECT        dbo.INVENTAIRE_STOCK_LIGNE.*, dbo.INVENTAIRE_STOCK.DEPOT_IS_ID, dbo.INVENTAIRE_STOCK.NOM_DEPOT_IS, dbo.INVENTAIRE_STOCK.TYPE_IS, dbo.INVENTAIRE_STOCK.STATUT_IS
FROM            dbo.INVENTAIRE_STOCK_LIGNE INNER JOIN
                         dbo.INVENTAIRE_STOCK ON dbo.INVENTAIRE_STOCK_LIGNE.IS_ID = dbo.INVENTAIRE_STOCK.ID_IS
GO

-----------------------------------------------------------------
IF OBJECT_ID('PRC_VALIDER_INVENTAIRE') IS NOT NULL  
    DROP PROCEDURE PRC_VALIDER_INVENTAIRE;  
GO
create PROCEDURE [dbo].[PRC_VALIDER_INVENTAIRE] 
@ID_TYPE_DOCUMENT numeric(18,0),
@ID_DOCUMENT numeric(18,0),
@ID_USER numeric(18,0),
@ID_SOCIETE numeric(18,0)

AS
BEGIN
declare @sql nvarchar(4000)
declare @n int
declare @TABLE_DOCUMENT varchar(100)
declare @TABLE_DOCUMENT_LIGNE varchar(100)

declare @NOM varchar(50)
declare @NUMERO varchar(50)
declare @TYPE_MOUVEMENT char(1)
declare @DATE_DOCUMENT date
declare @TYPE_IS varchar(10)

select @TABLE_DOCUMENT=TABLE_TD,@TABLE_DOCUMENT_LIGNE=TABLE_LIGNE_TD,
@NOM=NOM_TD,@TYPE_MOUVEMENT=TYPE_MOUVEMENT_TD
from TYPE_DOCUMENT where ID_TD=@ID_TYPE_DOCUMENT

set @sql='select @NUMERO=NUMERO_IS,@TYPE_IS=TYPE_IS from '+@TABLE_DOCUMENT+' where ID_IS='+cast(@ID_DOCUMENT as varchar(MAX))
execute sp_executesql @sql,N'@NUMERO varchar(50) output,@TYPE_IS varchar(10) output',@NUMERO output,@TYPE_IS output

BEGIN TRANSACTION

BEGIN TRY

set @sql='update '+@TABLE_DOCUMENT+' set STATUT_IS=''VALIDE'''+
	',USER_VALIDATION_IS_ID='+cast(@ID_USER as varchar(MAX))+',DATE_VALIDATION_IS=getdate()'+
	' where ID_IS='+cast(@ID_DOCUMENT as varchar(MAX)) 
set @sql=@sql+';select @n=@@ROWCOUNT'
execute sp_executesql @sql,N'@n int output',@n output

if @TYPE_IS='PARTIEL'
	Begin			
		set @sql='Delete INVENTAIRE_STOCK_LIGNE where IS_ID='+CAST(@ID_DOCUMENT as varchar(50))+ ' and ISNULL(ECART_IS_L,0)=0  '
		execute sp_executesql @sql
	End
							
if @n>0
Begin
	--Stock par depot
	set @sql='
		;with CTE as 
		(
		select ARTICLE_IS_L_ID,sum(ECART_IS_L) as ECART_IS_L,DEPOT_IS_ID,IS_ID
		from VUE_INVENTAIRE_STOCK_LIGNE
		where IS_ID='+CAST(@ID_DOCUMENT as varchar(50))+
		' group by ARTICLE_IS_L_ID,DEPOT_IS_ID,IS_ID
		)
		update STOCK_DEPOT set QUANTITE_STOCK_SD=D.QUANTITE_STOCK_SD+ISNULL(L.ECART_IS_L,0)   '
		+ ' from STOCK_DEPOT D '
		+ ' inner join CTE L on L.ARTICLE_IS_L_ID=D.ARTICLE_SD_ID and L.DEPOT_IS_ID=D.DEPOT_SD_ID  '
		+ ' where D.SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+ ' and L.IS_ID='+CAST(@ID_DOCUMENT as varchar(50))
		+ ' and exists(select 1 from ARTICLE A where A.ID_ARTICLE=L.ARTICLE_IS_L_ID and A.GESTION_STOCK=1) '
	set @sql=@sql+ ' and ISNULL(L.ECART_IS_L,0)<>0  '
	execute sp_executesql @sql

	set @sql='
		;with CTE as 
		(
		select ARTICLE_IS_L_ID,sum(QUANTITE_REEL_IS_L) as QUANTITE_REEL_IS_L,DEPOT_IS_ID,sum(ECART_IS_L) as ECART_IS_L,IS_ID
		from VUE_INVENTAIRE_STOCK_LIGNE
		where IS_ID='+CAST(@ID_DOCUMENT as varchar(50))+
		' group by ARTICLE_IS_L_ID,DEPOT_IS_ID,IS_ID
		)	
		insert STOCK_DEPOT (SOCIETE_ID,DEPOT_SD_ID,ARTICLE_SD_ID,QUANTITE_STOCK_SD)   '
		+ ' select '+CAST(@ID_SOCIETE as varchar(50))+',L.DEPOT_IS_ID,L.ARTICLE_IS_L_ID,L.QUANTITE_REEL_IS_L from CTE L '
		+ ' where not exists(select 1 from STOCK_DEPOT D where D.SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+' and L.DEPOT_IS_ID=D.DEPOT_SD_ID and L.ARTICLE_IS_L_ID=D.ARTICLE_SD_ID)  '
		+ ' and exists(select 1 from ARTICLE A where A.ID_ARTICLE=L.ARTICLE_IS_L_ID and A.GESTION_STOCK=1) '
	set @sql=@sql+ ' and ISNULL(L.ECART_IS_L,0)<>0 and QUANTITE_REEL_IS_L<>0  '
	execute sp_executesql @sql

	--Stock par depot propri?t?
	set @sql='update STOCK_PROPRIETE set QUANTITE_STOCK_PROPRIETE=D.QUANTITE_STOCK_PROPRIETE+ISNULL(L.ECART_IS_L,0)   '
	+ ' from STOCK_PROPRIETE D '
	+ ' inner join VUE_INVENTAIRE_STOCK_LIGNE L on L.ARTICLE_IS_L_ID=D.ARTICLE_PROPRIETE_ID and D.DEPOT_PROPRIETE_ID=L.DEPOT_IS_ID and D.TAILLE_PROPRIETE_ID=L.TAILLE_ID and D.COULEUR_PROPRIETE_ID=L.COULEUR_ID '
	+ ' where D.SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+ ' and L.IS_ID='+CAST(@ID_DOCUMENT as varchar(50))
	+ ' and exists(select 1 from ARTICLE A where A.ID_ARTICLE=L.ARTICLE_IS_L_ID and A.GESTION_STOCK=1) '
	set @sql=@sql+ ' and ISNULL(L.ECART_IS_L,0)<>0  '
	execute sp_executesql @sql

	set @sql='insert STOCK_PROPRIETE (SOCIETE_ID,DEPOT_PROPRIETE_ID,ARTICLE_PROPRIETE_ID,QUANTITE_STOCK_PROPRIETE,TAILLE_PROPRIETE_ID,COULEUR_PROPRIETE_ID)   '
		+ ' select '+CAST(@ID_SOCIETE as varchar(50))+',L.DEPOT_IS_ID,ARTICLE_IS_L_ID,QUANTITE_REEL_IS_L,TAILLE_ID,COULEUR_ID from VUE_INVENTAIRE_STOCK_LIGNE L '
		+ ' where IS_ID='+CAST(@ID_DOCUMENT as varchar(50))+' and '
		+ ' NOT EXISTS(select 1 from STOCK_PROPRIETE D where D.SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50))+' and L.DEPOT_IS_ID=D.DEPOT_PROPRIETE_ID and L.ARTICLE_IS_L_ID=D.ARTICLE_PROPRIETE_ID and D.TAILLE_PROPRIETE_ID=L.TAILLE_ID and D.COULEUR_PROPRIETE_ID=L.COULEUR_ID)  '
		+ ' and exists(select 1 from ARTICLE A where A.ID_ARTICLE=L.ARTICLE_IS_L_ID and A.GESTION_STOCK=1) '
	set @sql=@sql+ ' and ISNULL(L.ECART_IS_L,0)<>0 and L.QUANTITE_REEL_IS_L<>0  '
	execute sp_executesql @sql

	set @sql='insert MOUVEMENT_STOCK (SOCIETE_ID,TYPE_TIERS_MS,TIERS_MS_ID,NUMERO_TIERS_MS,NOM_TIERS_MS,
	DEPOT_MS_ID,NOM_DEPOT_MS,ARTICLE_MS_ID,ARTICLE_CODE_MS,LIBELLE_ARTICLE_MS,
	LIBELLE_MS,TYPE_DOCUMENT_MS,DOCUMENT_MS_ID,NUMERO_DOCUMENT_MS,QUANTITE_ENTREE_MS,
	QUANTITE_SORTIE_MS,USER_CREATION_ID) ' +
	' select ' 
	+ CAST(@ID_SOCIETE as varchar(50)) +','
	+'''STOCK'',NULL,NULL,NULL,'
	+ 'E.DEPOT_IS_ID,'
	+ 'NOM_DEPOT_IS,'
	+ 'L.ARTICLE_IS_L_ID,'
	+ 'L.ARTICLE_CODE_IS_L,'
	+ 'L.LIBELLE_ARTICLE_IS_L,'''
	+ @NOM+' '+@NUMERO +''','
	+ CAST(@ID_TYPE_DOCUMENT as varchar(50)) +','
	+ CAST(@ID_DOCUMENT as varchar(50)) + ','
	+ 'E.NUMERO_IS,'
	+ 'CASE WHEN ISNULL(L.ECART_IS_L,0)>0 THEN ECART_IS_L ELSE 0 END,CASE WHEN ISNULL(L.ECART_IS_L,0)<0 THEN -ISNULL(ECART_IS_L,0) ELSE 0 END, '
	+  CAST(@ID_USER as varchar(50)) 
	+ ' from ' + @TABLE_DOCUMENT_LIGNE + ' L'
	+ ' INNER JOIN ' + @TABLE_DOCUMENT + ' E'
	+ ' on E.ID_IS=L.IS_ID '
	+ ' where E.ID_IS=' + CAST(@ID_DOCUMENT as varchar(50)) 
	+' and exists(select 1 from ARTICLE A where A.ID_ARTICLE=L.ARTICLE_IS_L_ID and A.GESTION_STOCK=1)'
	set @sql=@sql+ ' and ISNULL(L.ECART_IS_L,0)<>0  '
	execute sp_executesql @sql

End 

select @n

END TRY
BEGIN CATCH  
	ROLLBACK TRANSACTION
	insert SQL_ERREUR (QUERY) values (@SQL)
	select -99,ERROR_NUMBER() 
	RETURN
END CATCH; 
COMMIT TRANSACTION

END
GO


----------------------------------------------------------------------------

insert [STOCK_PROPRIETE]
(
[SOCIETE_ID]
,[ARTICLE_PROPRIETE_ID]
,[TAILLE_PROPRIETE_ID]
,[COULEUR_PROPRIETE_ID]
,[DEPOT_PROPRIETE_ID]
,[QUANTITE_STOCK_PROPRIETE]
)

select 
[SOCIETE_ID]
,[ARTICLE_SD_ID]
,NULL
,NULL
,[DEPOT_SD_ID]
,[QUANTITE_STOCK_SD]
from STOCK_DEPOT

GO

-------------------------------------------------------------------------

update GRID set TABLE_GRID='VUE_ARTICLE_PROPRIETE',TABLE_GRID_UPDATE='VUE_ARTICLE_PROPRIETE' where ID_GRID=96

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+2
where GRID_ID=96 and ORDRE_COLONNE>=4

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1805,'96','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','4','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1806,'96','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','5','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=96
GO


----------------------------------------------------------------------

update GRID set TABLE_GRID='VUE_STOCK_DEPOT_PROPRIETE',TABLE_GRID_UPDATE='VUE_STOCK_DEPOT_PROPRIETE' where ID_GRID=97

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+2
where GRID_ID=97 and ORDRE_COLONNE>=4

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1807,'97','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','4','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1808,'97','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','5','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=97
GO


-------------------------------------------------------------------------


ALTER TABLE dbo.NUMERO_SERIE ADD
	TAILLE_ID numeric(18, 0) NULL,
	COULEUR_ID numeric(18, 0) NULL
GO

ALTER TABLE dbo.NUMERO_SERIE ADD
	NOM_TAILLE nvarchar(50) NULL,
	NOM_COULEUR nvarchar(50) NULL
GO
---------------------------------------------------------------------------

ALTER TRIGGER [dbo].[MOUVEMENT_STOCK_I]
   ON  [dbo].[MOUVEMENT_STOCK]
   AFTER INSERT
AS 
BEGIN

declare @ID_TYPE_DOCUMENT numeric(18,0)
declare @STATUT varchar(20) 
declare @ANNULATION bit
declare @DEVALIDATION bit
declare @ID_SOCIETE numeric(18,0)
declare @NOMBRE_DECIMAL int
declare @ID_DEPOT numeric(18,0)
declare @NOM_DEPOT nvarchar(200)

select @ID_TYPE_DOCUMENT=TYPE_DOCUMENT_MS,@ANNULATION=ANNULATION_DOCUMENT_MS,@DEVALIDATION=DEVALIDATION_DOCUMENT_MS,
@ID_SOCIETE=SOCIETE_ID,@ID_DEPOT=DEPOT_MS_ID,@NOM_DEPOT=NOM_DEPOT_MS from inserted
select @STATUT=CASE WHEN @ANNULATION=0 and @DEVALIDATION=0 THEN STATUT_NUMERO_SERIE_TD ELSE STATUT_ANNULE_NUMERO_SERIE_TD END from TYPE_DOCUMENT where ID_TD=@ID_TYPE_DOCUMENT
select @NOMBRE_DECIMAL=NOMBRE_DECIMAL from VUE_SOCIETE where ID_SOCIETE=@ID_SOCIETE


if @STATUT='VENDU'
	update NUMERO_SERIE set
	GARANTIE_MOIS_NS=A.GARANTIE_MOIS,
	DATE_DEBUT_GARANTIE_NS=CASE WHEN A.GARANTIE_MOIS is NULL THEN NULL ELSE I.DATE_CREATION END,
	DATE_FIN_GARANTIE_NS=CASE WHEN A.GARANTIE_MOIS is NULL THEN NULL ELSE DATEADD(MONTH,A.GARANTIE_MOIS,I.DATE_CREATION) END,
	STATUT_NS=@STATUT
	from NUMERO_SERIE NS 
	inner join Inserted I on NS.NUMERO_SERIE_NS=I.NUMERO_SERIE_MS and NS.SOCIETE_ID=I.SOCIETE_ID
	inner join ARTICLE A on A.ID_ARTICLE=NS.ARTICLE_NS_ID
	where ISNULL(I.NUMERO_SERIE_MS,'')<>''
Else
	update NUMERO_SERIE set
	GARANTIE_MOIS_NS=NULL,
	DATE_DEBUT_GARANTIE_NS=NULL,
	DATE_FIN_GARANTIE_NS=NULL,
	STATUT_NS=@STATUT
	from NUMERO_SERIE NS 
	inner join Inserted I on NS.NUMERO_SERIE_NS=I.NUMERO_SERIE_MS and NS.SOCIETE_ID=I.SOCIETE_ID
	inner join ARTICLE A on A.ID_ARTICLE=NS.ARTICLE_NS_ID
	where ISNULL(I.NUMERO_SERIE_MS,'')<>''


insert NUMERO_SERIE (
SOCIETE_ID,
ARTICLE_NS_ID,
CODE_ARTICLE_NS,
LIBELLE_ARTICLE_NS,
NUMERO_SERIE_NS,
QUANTITE_NS,
GARANTIE_MOIS_NS,
DATE_DEBUT_GARANTIE_NS,
DATE_FIN_GARANTIE_NS,
STATUT_NS,
DEPOT_NS_ID,
NOM_DEPOT_NS,
TAILLE_ID,
COULEUR_ID,
NOM_TAILLE,
NOM_COULEUR
)
select 
I.SOCIETE_ID,
I.ARTICLE_MS_ID,
I.ARTICLE_CODE_MS,
I.LIBELLE_ARTICLE_MS,
I.NUMERO_SERIE_MS,
I.QUANTITE_ENTREE_MS+I.QUANTITE_SORTIE_MS,
CASE WHEN I.QUANTITE_SORTIE_MS>0 THEN A.GARANTIE_MOIS ELSE NULL END,
CASE WHEN I.QUANTITE_SORTIE_MS>0 THEN CASE WHEN A.GARANTIE_MOIS is NULL THEN NULL ELSE I.DATE_CREATION END ELSE NULL END,
CASE WHEN I.QUANTITE_SORTIE_MS>0 THEN DATEADD(MONTH,A.GARANTIE_MOIS,I.DATE_CREATION) ELSE NULL END,
@STATUT,
@ID_DEPOT,
@NOM_DEPOT,
I.TAILLE_MS_ID,
I.COULEUR_MS_ID,
I.NOM_TAILLE_MS,
I.NOM_COULEUR_MS
from inserted I
inner join ARTICLE A on A.ID_ARTICLE=I.ARTICLE_MS_ID
where not exists (select 1 from NUMERO_SERIE NS where NS.NUMERO_SERIE_NS=I.NUMERO_SERIE_MS and NS.SOCIETE_ID=I.SOCIETE_ID)
and ISNULL(I.NUMERO_SERIE_MS,'')<>''


;WITH CTE as 
(
select ARTICLE_MS_ID,
ROUND(SUM(QUANTITE_ENTREE_MS*PRIX_ACHAT_MS)/SUM(QUANTITE_ENTREE_MS),@NOMBRE_DECIMAL) as PAMP
from MOUVEMENT_STOCK M
where exists (select 1 from Inserted I where I.ARTICLE_MS_ID=M.ARTICLE_MS_ID and I.PRIX_ACHAT_MS is NOT NULL)
and M.QUANTITE_ENTREE_MS>0 and PRIX_ACHAT_MS is NOT NULL
Group by ARTICLE_MS_ID
Having SUM(QUANTITE_ENTREE_MS)>0
)
update ARTICLE set PAMP_ARTICLE=C.PAMP
from ARTICLE A
inner join CTE C on A.ID_ARTICLE=C.ARTICLE_MS_ID

END

GO

-------------------------------------------------------------------

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+2
where GRID_ID=177 and ORDRE_COLONNE>=3

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1810,'177','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','4','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1811,'177','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','5','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=177
GO

------------------------------------------------------------

ALTER TABLE dbo.STOCK_BON_RECEPTION ADD
	TAILLE_ID numeric(18, 0) NULL,
	COULEUR_ID numeric(18, 0) NULL
GO

-------------------------------------------------------------

ALTER VIEW [dbo].[VUE_STOCK_BON_RECEPTION]
AS
SELECT        dbo.STOCK_BON_RECEPTION.ID_SBRF, dbo.STOCK_BON_RECEPTION.SOCIETE_ID, dbo.BON_RECEPTION_FOURNISSEUR.ID_BRF, dbo.BON_RECEPTION_FOURNISSEUR.NUMERO_BRF, 
                         dbo.BON_RECEPTION_FOURNISSEUR.DATE_BRF, dbo.BON_RECEPTION_FOURNISSEUR.FOURNISSEUR_BRF_ID, dbo.BON_RECEPTION_FOURNISSEUR.NOM_FOURNISSEUR_BRF, 
                         dbo.BON_RECEPTION_FOURNISSEUR.DOCUMENT_DOUANE_BRF, dbo.ARTICLE.ID_ARTICLE, dbo.ARTICLE.LIBELLE_ARTICLE, dbo.STOCK_BON_RECEPTION.QUANTITE_SBRF, dbo.ARTICLE.CODE_ARTICLE,
						 STOCK_BON_RECEPTION.TAILLE_ID,STOCK_BON_RECEPTION.COULEUR_ID,
						 TAILLE.NOM_TAILLE,COULEUR.NOM_COULEUR
FROM            dbo.STOCK_BON_RECEPTION INNER JOIN
                         dbo.BON_RECEPTION_FOURNISSEUR ON dbo.STOCK_BON_RECEPTION.BRF_SBRF_ID = dbo.BON_RECEPTION_FOURNISSEUR.ID_BRF INNER JOIN
                         dbo.ARTICLE ON dbo.STOCK_BON_RECEPTION.ARTICLE_SBRF_ID = dbo.ARTICLE.ID_ARTICLE
		LEFT JOIN TAILLE on TAILLE.ID_TAILLE=STOCK_BON_RECEPTION.TAILLE_ID
		LEFT JOIN COULEUR on COULEUR.ID_COULEUR=STOCK_BON_RECEPTION.COULEUR_ID
GO

---------------------------------------------------------------
-- AJOUTER TAILLE et COULEUR A LA PAGE STOCK BON DE RECEPTION (GRID 182)

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+2
where GRID_ID=182 and ORDRE_COLONNE>=6

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1812,'182','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','4','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1813,'182','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','5','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=182
GO

--------------------------------------------------------------------