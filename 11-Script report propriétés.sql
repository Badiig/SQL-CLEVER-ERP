
ALTER procedure [dbo].[PRC_IMP_ACHAT_ARTICLE] @DATE1 date,@DATE2 date,@ID_SOCIETE numeric(18,0)
as

SET DATEFORMAT dmy

select ARTICLE_CODE_MS as CODE_ARTICLE,MAX(LIBELLE_ARTICLE_MS) as LIBELLE_ARTICLE,
CAST(SUM(QUANTITE_ENTREE_MS)-SUM(QUANTITE_SORTIE_MS) as float) as ACHAT,
MAX(NOM_TAILLE_MS) as TAILLE,MAX(NOM_COULEUR_MS) as COULEUR
from MOUVEMENT_STOCK 
where SOCIETE_ID=@ID_SOCIETE and TYPE_TIERS_MS='FOURNISSEUR'
and DATE_MS>=ISNULL(@DATE1,'01/01/1900') and DATE_MS<=ISNULL(@DATE2,'31/12/2100')
Group by ARTICLE_CODE_MS,TAILLE_MS_ID,NOM_COULEUR_MS
Order by LIBELLE_ARTICLE

GO

----------------------------------------------------------------

ALTER procedure [dbo].[PRC_IMP_ARTICLE_DOCUMENT] @DATE1 date,@DATE2 date,@ID_SOCIETE numeric(18,0),@ID_TD numeric(18,0)
as

SET DATEFORMAT dmy

select ARTICLE_CODE_MS as CODE_ARTICLE,MAX(LIBELLE_ARTICLE_MS) as LIBELLE_ARTICLE,
cast(SUM(QUANTITE_SORTIE_MS)-SUM(QUANTITE_ENTREE_MS) as float) as VENTE,
MAX(NOM_TAILLE_MS) as TAILLE,MAX(NOM_COULEUR_MS) as COULEUR
from MOUVEMENT_STOCK 
where SOCIETE_ID=@ID_SOCIETE and TYPE_DOCUMENT_MS=@ID_TD
and DATE_MS>=ISNULL(@DATE1,'01/01/1900') and DATE_MS<=ISNULL(@DATE2,'31/12/2100')
Group by ARTICLE_CODE_MS,TAILLE_MS_ID,NOM_COULEUR_MS
Order by LIBELLE_ARTICLE

GO

-----------------------------------------------------------------------

ALTER procedure [dbo].[PRC_IMP_MOUVEMENT_ARTICLE] 
@ID_ARTICLE numeric(18,0),
@DATE1 date,
@DATE2 date,
@ID_TD numeric(18,0)
as

declare @sql nvarchar(MAX)
declare @NOMBRE_DECIMAL_SOCIETE int
declare @ID_SOCIETE numeric(18,0)

select @ID_SOCIETE=SOCIETE_ID from ARTICLE where ID_ARTICLE=@ID_ARTICLE

select @NOMBRE_DECIMAL_SOCIETE=NOMBRE_DECIMAL from SOCIETE S
inner join VUE_DEVISE D on S.DEVISE_SOCIETE_ID=D.ID_DEVISE
Where S.ID_SOCIETE=@ID_SOCIETE

SET DATEFORMAT dmy

BEGIN TRY

set @sql='select 
DATE_MS as [DATE],
TYPE_TIERS_MS as [TYPE],
NOM_TIERS_MS as [TIERS],
NOM_DEPOT_MS as [DEPOT],
NUMERO_DOCUMENT_MS as [DOCUMENT],
QUANTITE_ENTREE_MS as [ENTREE],
QUANTITE_SORTIE_MS as [SORTIE],
NOM_TAILLE_MS as TAILLE,
NOM_COULEUR_MS as COULEUR'
+' from MOUVEMENT_STOCK where '

set @sql=@sql+ ' ARTICLE_MS_ID='+CAST(@ID_ARTICLE as varchar(50)) 

if @DATE1 is not NULL
       set @sql=@sql+' and DATE_MS>='''+CAST(@DATE1 as varchar(50))+''''
if @DATE2 is not NULL
       set @sql=@sql+' and DATE_MS<='''+CAST(@DATE2 as varchar(50))+''''

if @ID_TD is not NULL set @sql=@sql+' and TYPE_DOCUMENT_MS='+CAST(@ID_TD as varchar(50))

set @sql=@sql+' order by [DATE]  '

Execute sp_executesql @sql
insert SQL_ERREUR (QUERY) values (@SQL)

END TRY
BEGIN CATCH  
       insert SQL_ERREUR (QUERY) values (@SQL)
       select -99 as RESULTAT,ERROR_NUMBER() 
       RETURN
END CATCH;  

GO

---------------------------------------------------------------------

ALTER procedure [dbo].[PRC_IMP_VENTE_ARTICLE] @DATE1 date,@DATE2 date,@ID_SOCIETE numeric(18,0)
as

SET DATEFORMAT dmy

select ARTICLE_CODE_MS as CODE_ARTICLE,MAX(LIBELLE_ARTICLE_MS) as LIBELLE_ARTICLE,
cast(SUM(QUANTITE_SORTIE_MS)-SUM(QUANTITE_ENTREE_MS) as float) as VENTE,
MAX(NOM_TAILLE_MS) as TAILLE,MAX(NOM_COULEUR_MS) as COULEUR
from MOUVEMENT_STOCK 
where SOCIETE_ID=@ID_SOCIETE and TYPE_TIERS_MS='CLIENT'
and DATE_MS>=ISNULL(@DATE1,'01/01/1900') and DATE_MS<=ISNULL(@DATE2,'31/12/2100')
Group by ARTICLE_CODE_MS,TAILLE_MS_ID,COULEUR_MS_ID
Order by LIBELLE_ARTICLE

GO

-------------------------------------------------------------------

