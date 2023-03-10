ALTER TABLE dbo.ARTICLE_COMPOSE ADD
	TAILLE_ID numeric(18, 0) NULL,
	COULEUR_ID numeric(18, 0) NULL
GO

ALTER TABLE dbo.ARTICLE_COMPOSE_LIGNE ADD
	TAILLE_ID numeric(18, 0) NULL,
	COULEUR_ID numeric(18, 0) NULL
GO

----------------------------------------------------------------------------
IF OBJECT_ID('PRC_AJOUTER_UN_ARTICLE_COMPOSE', 'P') IS NOT NULL  
    DROP PROCEDURE PRC_AJOUTER_UN_ARTICLE_COMPOSE;  
GO
CREATE PROCEDURE [dbo].[PRC_AJOUTER_UN_ARTICLE_COMPOSE] 
@ID_TYPE_DOCUMENT numeric(18,0),
@ID_DOCUMENT numeric(18,0),
@ID_ARTICLE numeric(18,0),
@ID_TIERS numeric(18,0),
@ID_DEVISE_SOCIETE numeric(18,0),
@ID_DEVISE_DOCUMENT numeric(18,0),
@QTE decimal(18,3),
@QUANTITE_COMPOSE decimal(18,3),
@ID_TAILLE numeric(18,0),
@ID_COULEUR numeric(18,0)

as
declare @sql nvarchar(MAX)
declare	@TABLE varchar(50)
declare	@TABLE_LIGNE varchar(50)
declare	@ABBREV_DOCUMENT varchar(10)
declare @VA varchar(50)
declare @N int
declare @EXONERATION_TAXE bit
declare @TABLE_ARTICLE varchar(50)
declare @TAUX_REMISE_CLIENT decimal(5,2)
declare @PRIX_ACHAT bit
declare @ID_SOCIETE numeric(18,0)
declare @ID_DOCUMENT_LIGNE numeric(18,0)
declare @NOM_TAILLE nvarchar(50)
declare @NOM_COULEUR nvarchar(50)

select @TABLE=TABLE_TD, @TABLE_LIGNE=TABLE_LIGNE_UPDATE_TD,@ABBREV_DOCUMENT=ABBREVIATION_TD,@VA=TYPE_VA_TD
from TYPE_DOCUMENT where ID_TD=@ID_TYPE_DOCUMENT

select @NOM_TAILLE=NOM_TAILLE from TAILLE where ID_TAILLE=@ID_TAILLE
select @NOM_COULEUR=NOM_COULEUR from COULEUR where ID_COULEUR=@ID_COULEUR

Begin Transaction
BEGIN TRY
	set @sql='Insert '+@TABLE_LIGNE+' ('+@ABBREV_DOCUMENT+'_ID) values ('+CAST(@ID_DOCUMENT as varchar(50))+')'
	set @sql=@sql+';select @ID_DOCUMENT_LIGNE=SCOPE_IDENTITY()'
	execute sp_executesql @sql,N'@ID_DOCUMENT_LIGNE numeric(18,0) output',@ID_DOCUMENT_LIGNE output

	set @sql='select  @ID_SOCIETE=SOCIETE_ID from '+@TABLE+' where ID_'+@ABBREV_DOCUMENT+'='+CAST(@ID_DOCUMENT as varchar(50))
	execute sp_executesql @sql,N'@ID_SOCIETE numeric(18,0) output',@ID_SOCIETE output

	select @PRIX_ACHAT=PRIX_ACHAT_SOCIETE from SOCIETE where ID_SOCIETE=@ID_SOCIETE

	if @VA='VENTE' 
		select @EXONERATION_TAXE=EXONERATION_TAXE_CLIENT,@TAUX_REMISE_CLIENT=TAUX_REMISE_CLIENT from CLIENT where ID_CLIENT=@ID_TIERS
	else
		select @EXONERATION_TAXE=EXONERATION_TAXE_FOURNISSEUR from FOURNISSEUR where ID_FOURNISSEUR=@ID_TIERS

	if @ID_DEVISE_SOCIETE=@ID_DEVISE_DOCUMENT
		set @TABLE_ARTICLE='VUE_ARTICLE'
	else
		set @TABLE_ARTICLE='VUE_ARTICLE_DEVISE'

	set @sql='update '+ @TABLE_LIGNE+' set
	ARTICLE_'+@ABBREV_DOCUMENT+'_L_ID=A.ID_ARTICLE,
	ARTICLE_CODE_'+@ABBREV_DOCUMENT+'_L=A.CODE_ARTICLE,
	LIBELLE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=A.LIBELLE_ARTICLE,'
	if @VA='VENTE' OR (@VA='ACHAT' and @PRIX_ACHAT=1)
		set @sql=@sql+'PRIX_'+@VA+'_ARTICLE_HT_BRUT_'+@ABBREV_DOCUMENT+'_L=A.PRIX_'+@VA+'_ARTICLE_HT,'
	Else
		set @sql=@sql++'PRIX_'+@VA+'_ARTICLE_HT_BRUT_'+@ABBREV_DOCUMENT+'_L=NULL,'

	set @sql=@sql+'TVA_ARTICLE_'+@ABBREV_DOCUMENT+'_L_ID=CASE WHEN '+CAST(@EXONERATION_TAXE as varchar(50))+'=0 THEN A.TVA_ARTICLE_ID ELSE NULL END,
	TAUX_ARTICLE_TVA_'+@ABBREV_DOCUMENT+'_L=CASE WHEN '+CAST(@EXONERATION_TAXE as varchar(50))+'=0 THEN A.TAUX_TVA_ARTICLE ELSE NULL END,
	TAUX_ARTICLE_TVA_ORIGINE_'+@ABBREV_DOCUMENT+'_L=A.TAUX_TVA_ARTICLE,
	UNITE_ARTICLE_'+@ABBREV_DOCUMENT+'_L_ID=A.UNITE_ARTICLE_ID,
	NOM_UNITE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=A.NOM_UNITE_ARTICLE,
	DEPOT_'+@ABBREV_DOCUMENT+'_L_ID=A.DEPOT_ARTICLE_ID,
	NOM_DEPOT_'+@ABBREV_DOCUMENT+'_L=A.NOM_DEPOT,'
	if @TAUX_REMISE_CLIENT is not NULL
		set @sql=@sql+'TAUX_REMISE_ARTICLE_'+@ABBREV_DOCUMENT+'_L='+CAST(@TAUX_REMISE_CLIENT as varchar(50))+','
	else
		set @sql=@sql+'TAUX_REMISE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=NULL,'
	if @QTE is not NULL
		set @sql=@sql+'QTE_ARTICLE_'+@ABBREV_DOCUMENT+'_L='+CAST(@QUANTITE_COMPOSE*@QTE as varchar(50))+','

	set @sql=@sql+'MONTANT_REMISE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=0'

	if ISNULL(@ID_TAILLE,'')=''
		set @sql=@sql+',TAILLE_'+@ABBREV_DOCUMENT+'_L_ID='+CAST(@ID_TAILLE as varchar(50))+',NOM_TAILLE_'+@ABBREV_DOCUMENT+'_L='''+@NOM_TAILLE+''''
	if ISNULL(@ID_COULEUR,'')=''
		set @sql=@sql+',COULEUR_'+@ABBREV_DOCUMENT+'_L_ID='+CAST(@ID_COULEUR as varchar(50))+',NOM_COULEUR_'+@ABBREV_DOCUMENT+'_L='''+@NOM_COULEUR+''''

	set @sql=@sql+' from '+@TABLE_ARTICLE+' A Where A.ID_ARTICLE='+CAST(@ID_ARTICLE as varchar(50))+' and ID_'+@ABBREV_DOCUMENT+'_L='+CAST(@ID_DOCUMENT_LIGNE as varchar(50))

	if @ID_DEVISE_SOCIETE<>@ID_DEVISE_DOCUMENT
		SET @sql=@sql+ ' and A.ID_DEVISE='+CAST(@ID_DEVISE_DOCUMENT as varchar(50))
	
	set @sql=@sql+';select @n=@@ROWCOUNT'
	execute sp_executesql @sql,N'@n int output',@n output

END TRY

BEGIN CATCH  
	ROLLBACK TRANSACTION
	if ERROR_NUMBER()=2627
		select -1
	else
		Begin
		insert SQL_ERREUR (QUERY) values (@sql)
		select -99 as RESULTAT,ERROR_NUMBER() 
		End
	RETURN
END CATCH; 

COMMIT TRANSACTION
GO
----------------------------------------------------------------------
IF OBJECT_ID('PRC_INSERER_ARTICLE_COMPOSE', 'P') IS NOT NULL  
    DROP PROCEDURE PRC_INSERER_ARTICLE_COMPOSE;  
GO

CREATE PROCEDURE [dbo].[PRC_INSERER_ARTICLE_COMPOSE] 
@ID_TYPE_DOCUMENT numeric(18,0),
@ID_DOCUMENT numeric(18,0),
@ID_ARTICLE_COMPOSE numeric(18,0),
@QTE decimal(18,3),
@ID_TAILLE numeric(18,0),
@ID_COULEUR numeric(18,0)

as
declare @sql nvarchar(MAX)
declare	@TABLE varchar(50)
declare	@TABLE_LIGNE varchar(50)
declare	@ABBREV_DOCUMENT varchar(10)
declare @TABLE_ARTICLE varchar(50)
declare @ID_SOCIETE numeric(18,0)
declare @ID_DOCUMENT_LIGNE numeric(18,0)
declare @N int
declare @NOM_TAILLE nvarchar(100)
declare @NOM_COULEUR nvarchar(100)

select @TABLE=TABLE_TD, @TABLE_LIGNE=TABLE_LIGNE_UPDATE_TD,@ABBREV_DOCUMENT=ABBREVIATION_TD
from TYPE_DOCUMENT where ID_TD=@ID_TYPE_DOCUMENT

select @NOM_TAILLE=NOM_TAILLE from TAILLE where ID_TAILLE=@ID_TAILLE
select @NOM_COULEUR=NOM_COULEUR from COULEUR where ID_COULEUR=@ID_COULEUR

Begin Transaction
BEGIN TRY
	set @sql='Insert '+@TABLE_LIGNE+' ('+@ABBREV_DOCUMENT+'_ID) values ('+CAST(@ID_DOCUMENT as varchar(50))+')'
	set @sql=@sql+';select @ID_DOCUMENT_LIGNE=SCOPE_IDENTITY()'
	execute sp_executesql @sql,N'@ID_DOCUMENT_LIGNE numeric(18,0) output',@ID_DOCUMENT_LIGNE output

	set @sql='select  @ID_SOCIETE=SOCIETE_ID from '+@TABLE+' where ID_'+@ABBREV_DOCUMENT+'='+CAST(@ID_DOCUMENT as varchar(50))
	execute sp_executesql @sql,N'@ID_SOCIETE numeric(18,0) output',@ID_SOCIETE output

	set @TABLE_ARTICLE='VUE_ARTICLE'

	set @sql='update '+ @TABLE_LIGNE+' set
	ARTICLE_'+@ABBREV_DOCUMENT+'_L_ID=A.ID_ARTICLE,
	ARTICLE_CODE_'+@ABBREV_DOCUMENT+'_L=A.CODE_ARTICLE,
	LIBELLE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=A.LIBELLE_ARTICLE,
	UNITE_ARTICLE_'+@ABBREV_DOCUMENT+'_L_ID=A.UNITE_ARTICLE_ID,
	NOM_UNITE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=A.NOM_UNITE_ARTICLE,
	DEPOT_'+@ABBREV_DOCUMENT+'_L_ID=A.DEPOT_ARTICLE_ID,
	NOM_DEPOT_'+@ABBREV_DOCUMENT+'_L=A.NOM_DEPOT,'
	if @QTE is NULL
		set @sql=@sql+'QTE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=NULL,'
	else
		set @sql=@sql+'QTE_ARTICLE_'+@ABBREV_DOCUMENT+'_L='+CAST(@QTE as varchar(50))+','
	set @sql=@sql+'MONTANT_REMISE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=NULL,'
	set @sql=@sql+'TAUX_REMISE_ARTICLE_'+@ABBREV_DOCUMENT+'_L=NULL,'
	set @sql=@sql+'ARTICLE_COMPOSE_'+@ABBREV_DOCUMENT+'_L=1'
	
	if @ID_TAILLE is NULL
		set @sql=@sql+',TAILLE_ID=NULL,NOM_TAILLE=NULL'
	else
		set @sql=@sql+',TAILLE_ID='+CAST(@ID_TAILLE as varchar(50))+',NOM_TAILLE='''+@NOM_TAILLE+''''
	if @ID_COULEUR is NULL
		set @sql=@sql+',COULEUR_ID=NULL,NOM_COULEUR=NULL'
	else
		set @sql=@sql+',COULEUR_ID='+CAST(@ID_COULEUR as varchar(50))+',NOM_COULEUR='''+@NOM_COULEUR+''''

	set @sql=@sql+' from '+@TABLE_ARTICLE+' A Where A.ID_ARTICLE='+CAST(@ID_ARTICLE_COMPOSE as varchar(50))+' and ID_'+@ABBREV_DOCUMENT+'_L='+CAST(@ID_DOCUMENT_LIGNE as varchar(50))
	set @sql=@sql+';select @n=@@ROWCOUNT'
	execute sp_executesql @sql,N'@n int output',@n output

END TRY

BEGIN CATCH  
	ROLLBACK TRANSACTION
	if ERROR_NUMBER()=2627
		select -1
	else
		Begin
		insert SQL_ERREUR (QUERY) values (@sql)
		select -99 as RESULTAT,ERROR_NUMBER() 
		End
	RETURN
END CATCH; 

COMMIT TRANSACTION

GO
------------------------------------------------------------------------
IF OBJECT_ID('PRC_AJOUTER_ARTICLE_COMPOSE', 'P') IS NOT NULL  
    DROP PROCEDURE PRC_AJOUTER_ARTICLE_COMPOSE;  
GO

CREATE PROCEDURE [dbo].[PRC_AJOUTER_ARTICLE_COMPOSE] 
@ID_TYPE_DOCUMENT numeric(18,0),
@ID_DOCUMENT numeric(18,0),
@ID_ARTICLE_COMPOSE numeric(18,0),
@QUANTITE bit,
@INSERER_ARTICLE_COMPOSE bit,
@QUANTITE_COMPOSE decimal(18,3),
@ID_TAILLE numeric(18,0),
@ID_COULEUR numeric(18,0)

as

declare @sql nvarchar(MAX)
declare @QTE decimal(18,3)
declare @ID_ARTICLE numeric(18,0)
declare @ID_ART numeric(18,0)
declare @ID_TIERS numeric(18,0)
declare @ID_DEVISE_SOCIETE numeric(18,0)
declare @ID_DEVISE_DOCUMENT numeric(18,0)
declare @ID_SOCIETE numeric(18,0)
declare	@TABLE_DOCUMENT varchar(50)
declare	@ABBREV_DOCUMENT varchar(10)
declare @TIERS varchar(50)

select @TABLE_DOCUMENT=TABLE_TD,@ABBREV_DOCUMENT=ABBREVIATION_TD,@TIERS=CASE WHEN VA_TD='V' THEN 'CLIENT' ELSE 'FOURNISSEUR' END from TYPE_DOCUMENT where ID_TD=@ID_TYPE_DOCUMENT
set @sql='select  @ID_SOCIETE=SOCIETE_ID,@ID_DEVISE_DOCUMENT=DEVISE_'+@ABBREV_DOCUMENT+'_ID,@ID_TIERS='+@TIERS+'_'+@ABBREV_DOCUMENT+'_ID'+' from '+@TABLE_DOCUMENT+' where ID_'+@ABBREV_DOCUMENT+'='+CAST(@ID_DOCUMENT as varchar(50))
execute sp_executesql @sql,N'@ID_SOCIETE numeric(18,0) output,@ID_DEVISE_DOCUMENT numeric(18,0) output,@ID_TIERS numeric(18,0) output',@ID_SOCIETE output,@ID_DEVISE_DOCUMENT output,@ID_TIERS output

select @ID_DEVISE_SOCIETE=DEVISE_SOCIETE_ID from SOCIETE where ID_SOCIETE=@ID_SOCIETE

if @INSERER_ARTICLE_COMPOSE=1
	Begin
		select @ID_ART=ARTICLE_ARTC_ID from ARTICLE_COMPOSE where ID_ARTC=@ID_ARTICLE_COMPOSE
		set @QUANTITE_COMPOSE= CASE WHEN @QUANTITE=0 THEN NULL ELSE @QUANTITE_COMPOSE END
		EXEC PRC_INSERER_ARTICLE_COMPOSE @ID_TYPE_DOCUMENT,@ID_DOCUMENT,@ID_ART,@QUANTITE_COMPOSE,@ID_TAILLE,@ID_COULEUR
	End
DECLARE cur_article CURSOR FOR   
SELECT  ARTICLE_ARTC_L_ID,CASE WHEN @QUANTITE=0 THEN NULL ELSE QTE_ARTC_L END as QTE_ARTC_L FROM ARTICLE_COMPOSE_LIGNE WHERE ARTC_ID=@ID_ARTICLE_COMPOSE  

OPEN cur_article  
  
FETCH NEXT FROM cur_article   
INTO @ID_ARTICLE, @QTE  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  

	set @sql='EXEC PRC_AJOUTER_UN_ARTICLE_COMPOSE '
		+ CAST(@ID_TYPE_DOCUMENT as varchar(50))+','
		+ CAST(@ID_DOCUMENT as varchar(50))+','
		+CAST(@ID_ARTICLE as varchar(50))+','
		+CAST(@ID_TIERS as varchar(50))+','
		+CAST(@ID_DEVISE_SOCIETE as varchar(50))+','
		+CAST(@ID_DEVISE_DOCUMENT as varchar(50))+','
		if @QTE is NULL
			set @sql=@sql+'NULL,'
		else
			set @sql=@sql+CAST(@QTE as varchar(50))+','
		if @QUANTITE_COMPOSE is NULL
			set @sql=@sql+'NULL'
		else
			set @sql=@sql+CAST(@QUANTITE_COMPOSE as varchar(50))+','
		if @ID_TAILLE is NULL
			set @sql=@sql+'NULL,'
		else
			set @sql=@sql+CAST(@ID_TAILLE as varchar(50))+','
		if @ID_COULEUR is NULL
			set @sql=@sql+'NULL'
		else
			set @sql=@sql+CAST(@ID_COULEUR as varchar(50))

	execute sp_executesql @sql

    FETCH NEXT FROM cur_article   
    INTO @ID_ARTICLE, @QTE  
END   
CLOSE cur_article;  
DEALLOCATE cur_article; 

select 1 as RESULTAT 

GO

----------------------------------------------------------------------------
IF OBJECT_ID('VUE_ARTICLE_COMPOSE', 'V') IS NOT NULL  
    DROP VIEW VUE_ARTICLE_COMPOSE;  
GO

CREATE VIEW [dbo].[VUE_ARTICLE_COMPOSE]
AS

with CTE as ( 
    SELECT AC.ID_ARTC,
	SUM(ROUND(L.PRIX_VENTE_ARTICLE_HT*QTE_ARTC_L,S.NOMBRE_DECIMAL)) as PRIX_VENTE_HT_ARTC ,
	SUM(ROUND(L.PRIX_VENTE_ARTICLE_TTC*QTE_ARTC_L,S.NOMBRE_DECIMAL)) as PRIX_VENTE_TTC_ARTC,
	AC.TAILLE_ID,AC.COULEUR_ID,MAX(TAILLE.NOM_TAILLE) as NOM_TAILLE,MAX(COULEUR.NOM_COULEUR) as NOM_COULEUR
	from ARTICLE_COMPOSE AC
	inner join VUE_SOCIETE S on S.ID_SOCIETE=AC.SOCIETE_ID
	left join VUE_ARTICLE_COMPOSE_LIGNE L on AC.ID_ARTC=L.ARTC_ID
	left join TAILLE on TAILLE.ID_TAILLE=AC.TAILLE_ID
	left join COULEUR on COULEUR.ID_COULEUR=AC.COULEUR_ID

	Group By AC.ID_ARTC,AC.TAILLE_ID,AC.COULEUR_ID,S.NOMBRE_DECIMAL
   ) 

select AC.*,
A.LIBELLE_ARTICLE, A.NOM_FAMILLE_ARTICLE, A.NOM_MARQUE_ARTICLE, 
A.NOM_CATEGORIE_ARTICLE, A.CODE_ARTICLE, A.ID_ARTICLE,
C.PRIX_VENTE_HT_ARTC,C.PRIX_VENTE_TTC_ARTC,
C.NOM_TAILLE,C.NOM_COULEUR
from ARTICLE_COMPOSE AC
inner join CTE C on C.ID_ARTC=AC.ID_ARTC
inner join VUE_ARTICLE A on A.ID_ARTICLE=AC.ARTICLE_ARTC_ID

GO

---------------------------------------------------------------------------------------
IF OBJECT_ID('VUE_ARTICLE_COMPOSE_LIGNE', 'V') IS NOT NULL  
    DROP VIEW VUE_ARTICLE_COMPOSE_LIGNE;  
GO
CREATE VIEW [dbo].[VUE_ARTICLE_COMPOSE_LIGNE]
AS
SELECT        
dbo.ARTICLE_COMPOSE_LIGNE.ID_ARTC_L, dbo.ARTICLE_COMPOSE_LIGNE.ARTC_ID, dbo.ARTICLE_COMPOSE_LIGNE.QTE_ARTC_L, dbo.ARTICLE.LIBELLE_ARTICLE, dbo.ARTICLE.CODE_ARTICLE, 
dbo.ARTICLE_COMPOSE_LIGNE.ARTICLE_ARTC_L_ID, dbo.ARTICLE.PRIX_VENTE_ARTICLE_HT, dbo.ARTICLE.PRIX_VENTE_ARTICLE_TTC, dbo.ARTICLE.SOCIETE_ID,
ARTICLE_COMPOSE_LIGNE.TAILLE_ID,ARTICLE_COMPOSE_LIGNE.COULEUR_ID,TAILLE.NOM_TAILLE,COULEUR.NOM_COULEUR			
FROM  dbo.ARTICLE_COMPOSE_LIGNE 
LEFT OUTER JOIN dbo.ARTICLE ON dbo.ARTICLE.ID_ARTICLE = dbo.ARTICLE_COMPOSE_LIGNE.ARTICLE_ARTC_L_ID
LEFT OUTER JOIN dbo.ARTICLE_PROPRIETE ON dbo.ARTICLE.ID_ARTICLE=dbo.ARTICLE_PROPRIETE.ARTICLE_ID
and dbo.ARTICLE_PROPRIETE.TAILLE_ID=dbo.ARTICLE_COMPOSE_LIGNE.TAILLE_ID
and dbo.ARTICLE_PROPRIETE.COULEUR_ID=dbo.ARTICLE_COMPOSE_LIGNE.COULEUR_ID
LEFT JOIN TAILLE on TAILLE.ID_TAILLE=ARTICLE_COMPOSE_LIGNE.TAILLE_ID
LEFT JOIN COULEUR on COULEUR.ID_COULEUR=ARTICLE_COMPOSE_LIGNE.COULEUR_ID
GO

------------------------------------------------------------------------------------------

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+4 where GRID_ID=155 and ORDRE_COLONNE>=5

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1773,'155','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','5','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1774,'155','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','1','0','0','1','0','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1775,'155','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','1','0','0','0','0','0','1','0','7','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1776,'155','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','1','0','0','0','0','0','1','0','8','NUMERIC','L')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=155


GO

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1777,'156','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','3','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1778,'156','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','4','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1779,'156','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','5','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1780,'156','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','6','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=156

GO

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+4 where GRID_ID=157 and ORDRE_COLONNE>=4
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1781,'157','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','4','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1782,'157','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','5','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1783,'157','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1784,'157','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','7','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=157

GO

update GRID_COLONNE set ORDRE_COLONNE=ORDRE_COLONNE+4 where GRID_ID=158 and ORDRE_COLONNE>=4
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1785,'158','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','4','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1786,'158','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','5','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1787,'158','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1788,'158','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','7','TEXT','C')

update GRID_COLONNE_USER set ORDRE_GRID_COLONNE_USER=ORDRE_COLONNE
from GRID_COLONNE_USER
inner join GRID_COLONNE
on GRID_COLONNE_USER.GRID_COLONNE_ID=GRID_COLONNE.ID_GRID_COLONNE
where GRID_COLONNE.GRID_ID=158

GO


------------------------------------------------------------------

update GRID set TABLE_GRID='VUE_ARTICLE_PROPRIETE',TABLE_GRID_UPDATE='VUE_ARTICLE_PROPRIETE'
where ID_GRID=163

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1789,'163','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','4','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1790,'163','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','5','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1791,'163','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1792,'163','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','7','TEXT','C')

update GRID set NOM_GRID='LISTE ARTICLE 4',CONDITION_PARTICULIERE_GRID='NOT EXISTS (select 1 from ARTICLE_COMPOSE where VUE_ARTICLE_PROPRIETE.ID_ARTICLE=ARTICLE_COMPOSE.ARTICLE_ARTC_ID)',CONDITION_SOCIETE_GRID='1',TABLE_GRID='VUE_ARTICLE_PROPRIETE',KEY_ID_GRID='ID_ARTICLE',CHAMPS_ID_GRID=NULL where  ID_GRID=' 163' 

GO

---------------------------------------------------------------------

update GRID set TABLE_GRID='VUE_ARTICLE_PROPRIETE',TABLE_GRID_UPDATE='VUE_ARTICLE_PROPRIETE'
where ID_GRID=98

insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1793,'98','TAILLE_ID','TAILLE_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','4','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1794,'98','COULEUR_ID','COULEUR_ID',NULL,NULL,'0',NULL,'100','1','0','0','0','0','0','0','0','1','0','5','NUMERIC','L')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1795,'98','NOM_TAILLE','TAILLE',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','6','TEXT','C')
insert GRID_COLONNE  (ID_GRID_COLONNE,GRID_ID,CHAMPS_COLONNE,NOM_COLONNE,LISTE_COLONNE,VALEUR_DEFAUT_COLONNE,LARGEUR_COLONNE,CHECK_COLONNE,LONGUEUR_TYPE_COLONNE,ACTIF_COLONNE,VISIBLE_COLONNE,READONLY_COLONNE,MONNAIE_COLONNE,GRID_LISTE_COLONNE,CALCULE_COLONNE,TRONQUER_ZERO_COLONNE,ZERO_VIDE_COLONNE,ACCEPTER_NULL_COLONNE,VISIBLE_DEFAUT_COLONNE,ORDRE_COLONNE,TYPE_COLONNE,ALIGN_COLONNE) values (1796,'98','NOM_COULEUR','COULEUR',NULL,NULL,'80',NULL,'100','1','1','1','0','0','0','0','0','1','0','7','TEXT','C')
GO

-----------------------------------------------------------------------------------
IF OBJECT_ID('PRC_MAJ_DOCUMENT_LIGNE_ARTICLE_COMPOSE', 'P') IS NOT NULL  
    DROP PROCEDURE PRC_MAJ_DOCUMENT_LIGNE_ARTICLE_COMPOSE;  
GO
CREATE PROCEDURE [dbo].[PRC_MAJ_DOCUMENT_LIGNE_ARTICLE_COMPOSE] 
@ID_DOCUMENT_LIGNE numeric(18,0),
@ID_ARTICLE numeric(18,0),
@ID_TAILLE numeric(18,0)=NULL,
@ID_COULEUR numeric(18,0)=NULL
AS
BEGIN 

declare @sql  nvarchar(MAX)
declare @n int

Begin Transaction

BEGIN TRY

set @sql='update ARTICLE_COMPOSE_LIGNE set ARTICLE_ARTC_L_ID='+CAST(@ID_ARTICLE as varchar(50))
if @ID_TAILLE is not NULL
	set @sql=@sql+',TAILLE_ID='+CAST(@ID_TAILLE as varchar(50))

if @ID_COULEUR is not NULL
	set @sql=@sql+',COULEUR_ID='+CAST(@ID_COULEUR as varchar(50))

set @sql=@sql+' where ID_ARTC_L='+CAST(@ID_DOCUMENT_LIGNE as varchar(50))

set @sql=@sql+';select @n=@@ROWCOUNT'
execute sp_executesql @sql,N'@n int output',@n output
select @n

END TRY
BEGIN CATCH  
	ROLLBACK TRANSACTION
	insert SQL_ERREUR (QUERY) values (@SQL)
	select 0,ERROR_NUMBER() 
	RETURN
END CATCH;  

Commit Transaction

END

GO

---------------------------------------------------------------------


insert CONTROLE  (ID_CTRL,PAGE_ID,ID_DESIGN_CTRL,VALEUR_DEFAUT_CTRL,LISTE_DDL,VALEUR_VIDE_CTRL,CHAMPS_CALCULE_CTRL,MODIFIABLE_INSERT_CTRL,MODIFIABLE_UPDATE_CTRL,CHAMPS_CACHE_CTRL,MONNAIE_CTRL,TRONQUER_ZERO_CTRL,CHAMPS_CTRL) values (994,'69','C12',NULL,NULL,NULL,'1','0','0','0','0','0','NOM_COULEUR')
insert CONTROLE  (ID_CTRL,PAGE_ID,ID_DESIGN_CTRL,VALEUR_DEFAUT_CTRL,LISTE_DDL,VALEUR_VIDE_CTRL,CHAMPS_CALCULE_CTRL,MODIFIABLE_INSERT_CTRL,MODIFIABLE_UPDATE_CTRL,CHAMPS_CACHE_CTRL,MONNAIE_CTRL,TRONQUER_ZERO_CTRL,CHAMPS_CTRL) values (995,'69','C11',NULL,NULL,'','1','0','0','0','0','0','NOM_TAILLE')

