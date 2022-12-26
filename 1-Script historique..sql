
------------------------------SOCIETE HISTORIQUE------------------------------

drop table SOCIETE_HISTORIQUE
GO

CREATE TABLE [dbo].[SOCIETE_HISTORIQUE]
([ID_HISTORIQUE] [int] IDENTITY(1,1) NOT NULL,
	[ID_SOCIETE] [numeric](18, 0) NULL,
	[ID_USER] [numeric](18, 0) NULL,
	[NOM_USER] [varchar](50) NULL,
	[HISTORIQUE] [varchar](max) NULL,
	[DATE] [datetime] DEFAULT getdate()
)
GO

	
ALTER TRIGGER  [dbo].[SOCIETE_U]
   ON  [dbo].[SOCIETE]
   AFTER UPDATE
AS 
BEGIN

declare @ID_USER numeric(18,0)
declare @NOM_USER nvarchar(200)

select @ID_USER=USER_MODIF_ID from inserted
select @NOM_USER=NOM_USER + ' ' + PRENOM_USER from [USER] where ID_USER=@ID_USER

if UPDATE(GESTION_STOCK) and (select GESTION_STOCK from inserted)<>(select GESTION_STOCK from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Gestion stock est ' + CASE WHEN GESTION_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted


if UPDATE(STOCK_ZERO_NEGATIF) and (select STOCK_ZERO_NEGATIF from inserted)<>(select STOCK_ZERO_NEGATIF from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Autorisée stock négatif est '+CASE WHEN STOCK_ZERO_NEGATIF = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(TIMBRE_SOCIETE) and (select TIMBRE_SOCIETE from inserted)<>(select TIMBRE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Calcul timbre est '+CASE WHEN TIMBRE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(FODEC_ACHAT_SOCIETE) and (select FODEC_ACHAT_SOCIETE from inserted)<>(select FODEC_ACHAT_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Fodec achat est '+CASE WHEN FODEC_ACHAT_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(FODEC_VENTE_SOCIETE) and (select FODEC_VENTE_SOCIETE from inserted)<>(select FODEC_VENTE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Fodec vente est '+CASE WHEN FODEC_VENTE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(MAJ_PRIX_ACHAT_SOCIETE) and (select MAJ_PRIX_ACHAT_SOCIETE from inserted)<>(select MAJ_PRIX_ACHAT_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Mise à jour prix achat est '+CASE WHEN MAJ_PRIX_ACHAT_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(MAJ_MARGE_SOCIETE) and (select MAJ_MARGE_SOCIETE from inserted)<>(select MAJ_MARGE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Mise à jour marge est '+CASE WHEN MAJ_MARGE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(MAJ_PRIX_VENTE_SOCIETE) and (select MAJ_PRIX_VENTE_SOCIETE from inserted)<>(select MAJ_PRIX_VENTE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Mise à jour prix vente est '+CASE WHEN MAJ_PRIX_VENTE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(PRIX_ACHAT_SOCIETE) and (select PRIX_ACHAT_SOCIETE from inserted)<>(select PRIX_ACHAT_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Prix achat est '+CASE WHEN PRIX_ACHAT_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(TPE_ACHAT_SOCIETE) and (select TPE_ACHAT_SOCIETE from inserted)<>(select TPE_ACHAT_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Tpe achat est '+CASE WHEN TPE_ACHAT_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(TPE_VENTE_SOCIETE) and (select TPE_VENTE_SOCIETE from inserted)<>(select TPE_VENTE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Tpe vente est '+CASE WHEN TPE_VENTE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(FACTURE_CLIENT_STOCK) and (select FACTURE_CLIENT_STOCK from inserted)<>(select FACTURE_CLIENT_STOCK from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Facture client stock est '+CASE WHEN FACTURE_CLIENT_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(FACTURE_FOURNISSEUR_STOCK) and (select FACTURE_FOURNISSEUR_STOCK from inserted)<>(select FACTURE_FOURNISSEUR_STOCK from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Facture fournisseur stock est '+CASE WHEN FACTURE_FOURNISSEUR_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(AVOIR_CLIENT_STOCK) and (select AVOIR_CLIENT_STOCK from inserted)<>(select AVOIR_CLIENT_STOCK from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Avoir client stock est '+CASE WHEN AVOIR_CLIENT_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(AVOIR_FOURNISSEUR_STOCK) and (select AVOIR_FOURNISSEUR_STOCK from inserted)<>(select AVOIR_FOURNISSEUR_STOCK from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Avoir fournisseur stock est '+CASE WHEN AVOIR_FOURNISSEUR_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(NUMERO_SERIE_OBLIGATOIRE_SOCIETE) and (select NUMERO_SERIE_OBLIGATOIRE_SOCIETE from inserted)<>(select NUMERO_SERIE_OBLIGATOIRE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Numéro serie obligatoire est '+CASE WHEN NUMERO_SERIE_OBLIGATOIRE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(NUMERO_SERIE_UNIQUE_SOCIETE) and (select NUMERO_SERIE_UNIQUE_SOCIETE from inserted)<>(select NUMERO_SERIE_UNIQUE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Numéro serie unique est '+CASE WHEN NUMERO_SERIE_UNIQUE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

if UPDATE(REINITIALISER_PARAM_CAISSE_SOCIETE) and (select REINITIALISER_PARAM_CAISSE_SOCIETE from inserted)<>(select REINITIALISER_PARAM_CAISSE_SOCIETE from deleted)
	insert SOCIETE_HISTORIQUE
	(
	ID_SOCIETE,
	ID_USER,
	NOM_USER,
	HISTORIQUE
	)
	select 
	ID_SOCIETE,
	@ID_USER,
	@NOM_USER,
	'Rénitialiser caisse est '+CASE WHEN REINITIALISER_PARAM_CAISSE_SOCIETE = 1 THEN 'activé' ELSE 'désactivé' END
	from inserted

END

GO


------------------------------RAPPORT GESTION PROJET------------------------------


insert IMPRESSION
select 40,'LISTE DES PROJETS'
GO

CREATE procedure [dbo].[PRC_IMP_LISTE_PROJETS] @ID_SOCIETE numeric(18,0),@ID_CLIENT numeric(18,0),@DATE1 date,@DATE2 date,@ENCOURS bit
as

declare @sql nvarchar(2000)
declare @NOMBRE_DECIMAL_SOCIETE int

select @NOMBRE_DECIMAL_SOCIETE=NOMBRE_DECIMAL from SOCIETE S
inner join VUE_DEVISE D on S.DEVISE_SOCIETE_ID=D.ID_DEVISE
Where S.ID_SOCIETE=@ID_SOCIETE

BEGIN TRY

set @sql='SELECT NOM_GP,NUMERO_GP,COMPTEUR_GP,STATUT_GP,STATUT_COMPLET_GP,CLIENT_GP_ID,NUMERO_CLIENT_GP,NOM_CLIENT_GP,
MONTANT_GP,PAIEMENT_GP,FACTURER_GP,RESTE_PAYER_GP,CHARGE_GP,BENEFICE_GP from GESTION_PROJET '
+ ' where STATUT_GP<>''ANNULE'' and SOCIETE_ID='+CAST(@ID_SOCIETE as varchar(50)) 
if @ID_CLIENT IS NOT NULL
	set @sql=@sql+ ' and CLIENT_GP_ID='+CAST(@ID_CLIENT as varchar(50))

if @DATE1 is not NULL
	set @sql=@sql+ ' and DATE_DEBUT_PREVU_GP>='''+CAST(@DATE1 as varchar(10)) + ''''

if @DATE2 is not NULL
	set @sql=@sql+ ' and DATE_DEBUT_FIN_GP<='''+CAST(@DATE2 as varchar(10)) + ''''

if @ENCOURS=0
	set @sql=@sql+ ' and STATUT_GP<>''ENCOURS'''


set @sql=@sql+ ' ORDER BY CLIENT_GP_ID '

Execute sp_executesql @sql

END TRY
BEGIN CATCH  
	insert SQL_ERREUR (QUERY) values (@SQL)
	select -99 as RESULTAT,ERROR_NUMBER() 
	RETURN
END CATCH;  

GO


------------------------------ARTICLE HISTORIQUE------------------------------

DROP TABLE ARTICLE_HISTORIQUE
GO

CREATE TABLE [dbo].[ARTICLE_HISTORIQUE]
(
	[ID_HISTORIQUE] [int] IDENTITY(1,1) NOT NULL,
	[ID_SOCIETE] [numeric](18, 0) NULL,
	[ID_ARTICLE] [numeric](18, 0) NULL,
	[ID_USER] [numeric](18, 0) NULL,
	[NOM_USER] [varchar](50) NULL,
	[HISTORIQUE] [varchar](max) NULL,
	[DATE] [datetime] DEFAULT getdate()
)
GO




ALTER TRIGGER [dbo].[ARTICLE_U] 
   ON  [dbo].[ARTICLE]
   AFTER UPDATE
AS 
BEGIN

declare @ID numeric(18,0)
declare @CODE_ARTICLE varchar(50)
declare @sql nvarchar(2000)
declare @TYPE_CALCUL varchar(50)
declare @ID_SOCIETE numeric(18,0)
declare @ID_USER numeric(18,0)
declare @NOM_USER nvarchar(200)

declare @NOMBRE_DECIMAL int


select @ID=ID_ARTICLE,@CODE_ARTICLE=CODE_ARTICLE,@TYPE_CALCUL=TYPE_CALCUL,@ID_SOCIETE=SOCIETE_ID,@ID_USER=USER_MODIF_ID
from Inserted

select @NOM_USER=NOM_USER + ' ' + PRENOM_USER from [USER] where ID_USER=@ID_USER

select @NOMBRE_DECIMAL=NOMBRE_DECIMAL from VUE_SOCIETE where ID_SOCIETE=@ID_SOCIETE

BEGIN TRANSACTION

BEGIN TRY

if update("MARGE_ARTICLE") or update("PRIX_ACHAT_ARTICLE_HT") 
or  update("PRIX_VENTE_ARTICLE_HT") or update("TVA_ARTICLE_ID") or update("PRIX_ACHAT_ARTICLE_TTC")
or update ("CHARGE_ARTICLE")
	Begin
		if @TYPE_CALCUL='LE PRIX DE VENTE TTC' 
			Begin
				set @sql='update ARTICLE set PRIX_VENTE_ARTICLE_HT=
				CASE WHEN ISNULL(PRIX_VENTE_ARTICLE_TTC,0)=0 THEN NULL 
					 ELSE CAST(A.PRIX_VENTE_ARTICLE_TTC/(1+ISNULL(T.TAUX_TVA_ARTICLE,0)/100) as decimal(38,'+CAST(@NOMBRE_DECIMAL as varchar(50))+'))-ISNULL(CHARGE_ARTICLE,0) END  '
				+' from ARTICLE A'
				+' left join TVA_ARTICLE T on T.ID_TVA_ARTICLE=A.TVA_ARTICLE_ID '
				+ 'where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql

				set @sql='update ARTICLE set MARGE_ARTICLE=
				CASE WHEN ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0)=0 or ISNULL(PRIX_VENTE_ARTICLE_HT,0)=0 THEN NULL 
					 ELSE CASE WHEN ISNULL(PRIX_VENTE_ARTICLE_HT,0)<=ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0) THEN 0 ELSE CAST(((ISNULL(PRIX_VENTE_ARTICLE_HT,0)-ISNULL(PRIX_ACHAT_ARTICLE_HT,0)-ISNULL(CHARGE_ARTICLE,0))/(ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0)))*100 as decimal(10,2)) END END  
				where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql
			End
		if @TYPE_CALCUL='LE PRIX DE VENTE HT' 
			Begin
				set @sql='update ARTICLE set MARGE_ARTICLE=
				CASE WHEN ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0)=0 or ISNULL(PRIX_VENTE_ARTICLE_HT,0)=0 THEN NULL 
					 ELSE CASE WHEN ISNULL(PRIX_VENTE_ARTICLE_HT,0)<=ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0) THEN 0 ELSE CAST(((ISNULL(PRIX_VENTE_ARTICLE_HT,0)-ISNULL(PRIX_ACHAT_ARTICLE_HT,0))/(ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0)))*100 as decimal(10,2)) END END  
				where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql

				set @sql='Update ARTICLE set '+
				'PRIX_VENTE_ARTICLE_TTC=CAST(ISNULL(A.PRIX_VENTE_ARTICLE_HT,0)*(1+ISNULL(T.TAUX_TVA_ARTICLE,0)/100) as decimal(38,'+CAST(@NOMBRE_DECIMAL as varchar(50))+'))' --,'
				+' from ARTICLE A'
				+' left join TVA_ARTICLE T on T.ID_TVA_ARTICLE=A.TVA_ARTICLE_ID '
				+' where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql
			End
		if @TYPE_CALCUL='LE COEFFICIENT DE MARGE'
			Begin
				set @sql='update ARTICLE set PRIX_VENTE_ARTICLE_HT=
				CASE WHEN MARGE_ARTICLE is NULL THEN NULL 
					 ELSE CAST((ISNULL(PRIX_ACHAT_ARTICLE_HT,0)+ISNULL(CHARGE_ARTICLE,0))*(1+MARGE_ARTICLE/100) as decimal(38,'+CAST(@NOMBRE_DECIMAL as varchar(50))+')) END'  
				+ ' where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql

				set @sql='Update ARTICLE set '+
				'PRIX_VENTE_ARTICLE_TTC=CAST(A.PRIX_VENTE_ARTICLE_HT*(1+ISNULL(T.TAUX_TVA_ARTICLE,0)/100) as decimal(38,'+CAST(@NOMBRE_DECIMAL as varchar(50))+'))'--,'
				+' from ARTICLE A'
				+' left join TVA_ARTICLE T on T.ID_TVA_ARTICLE=A.TVA_ARTICLE_ID '
				+' where ID_ARTICLE='+CAST(@ID as varchar(50))
				execute sp_executesql @sql
			End
	End


if UPDATE(LIBELLE_ARTICLE) and (select LIBELLE_ARTICLE from inserted)<>(select LIBELLE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le libélle est changé de '+(select LIBELLE_ARTICLE from deleted)+' à '+(select LIBELLE_ARTICLE from inserted) 
from inserted

if UPDATE(CODE_ARTICLE) and (select CODE_ARTICLE from inserted)<>(select CODE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le code est changé de '+(select CODE_ARTICLE from deleted)+' à '+(select CODE_ARTICLE from inserted) 
from inserted

if UPDATE(CODE_BARRE_ARTICLE) and ISNULL((select CODE_BARRE_ARTICLE from inserted),'')<>ISNULL((select CODE_BARRE_ARTICLE from deleted),'')
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le code à barre est changé de '+ISNULL((select CODE_BARRE_ARTICLE from deleted),'rien')+' à '+ISNULL((select CODE_BARRE_ARTICLE from inserted),'rien')
from inserted

if UPDATE(PRIX_ACHAT_ARTICLE_HT) and (select PRIX_ACHAT_ARTICLE_HT from inserted)<>(select PRIX_ACHAT_ARTICLE_HT from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le prix d''achat HT est changé de '+ISNULL((select CAST(CAST(PRIX_ACHAT_ARTICLE_HT as decimal(18,3)) as varchar(50)) from deleted),'rien')+' à '+ISNULL((select CAST(CAST(PRIX_ACHAT_ARTICLE_HT as decimal(18,3)) as varchar(50)) from inserted),'rien') 
from inserted

if UPDATE(PRIX_ACHAT_ARTICLE_TTC) and (select PRIX_ACHAT_ARTICLE_TTC from inserted)<>(select PRIX_ACHAT_ARTICLE_TTC from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le prix d''achat TTC est changé de '+ISNULL((select CAST(CAST(PRIX_ACHAT_ARTICLE_TTC as decimal(18,3)) as varchar(50)) from deleted),'rien')+' à '+ISNULL((select CAST(CAST(PRIX_ACHAT_ARTICLE_TTC as decimal(18,3)) as varchar(50)) from inserted),'rien') 
from inserted
	
if UPDATE(PRIX_VENTE_ARTICLE_HT) and (select PRIX_VENTE_ARTICLE_HT from inserted)<>(select PRIX_VENTE_ARTICLE_HT from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le prix de vente HT est changé de '+ISNULL((select CAST(CAST(PRIX_VENTE_ARTICLE_HT as decimal(18,3)) as varchar(50)) from deleted),'rien')+' à '+ISNULL((select CAST(CAST(PRIX_VENTE_ARTICLE_HT as decimal(18,3)) as varchar(50)) from inserted),'rien') 
from inserted

if UPDATE(PRIX_VENTE_ARTICLE_TTC) and (select PRIX_VENTE_ARTICLE_TTC from inserted)<>(select PRIX_VENTE_ARTICLE_TTC from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Le prix de vente TTC est changé de '+ISNULL((select CAST(CAST(PRIX_VENTE_ARTICLE_TTC as decimal(18,3)) as varchar(50)) from deleted),'rien')+' à '+ISNULL((select CAST(CAST(PRIX_VENTE_ARTICLE_TTC as decimal(18,3)) as varchar(50)) from inserted),'rien') 
from inserted


if UPDATE(GESTION_STOCK) and (select GESTION_STOCK from inserted)<>(select GESTION_STOCK from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Gestion stock est ' + CASE WHEN GESTION_STOCK = 1 THEN 'activé' ELSE 'désactivé' END
from inserted


if UPDATE(BLOQUE_ARTICLE) and (select BLOQUE_ARTICLE from inserted)<>(select BLOQUE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'L''article est ' + CASE WHEN BLOQUE_ARTICLE = 1 THEN 'bloqué' ELSE 'débloqué' END
from inserted


if UPDATE(FODEC_ACHAT_ARTICLE) and (select FODEC_ACHAT_ARTICLE from inserted)<>(select FODEC_ACHAT_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Fodec achat est ' + CASE WHEN FODEC_ACHAT_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(FODEC_VENTE_ARTICLE) and (select FODEC_VENTE_ARTICLE from inserted)<>(select FODEC_VENTE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Fodec vente est ' + CASE WHEN FODEC_VENTE_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(TPE_ACHAT_ARTICLE) and (select TPE_ACHAT_ARTICLE from inserted)<>(select TPE_ACHAT_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'TPE achat est ' + CASE WHEN TPE_ACHAT_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(TPE_VENTE_ARTICLE) and (select TPE_VENTE_ARTICLE from inserted)<>(select TPE_VENTE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'TPE vente est ' + CASE WHEN TPE_VENTE_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(NUMERO_SERIE_OBLIGATOIRE_ARTICLE) and (select NUMERO_SERIE_OBLIGATOIRE_ARTICLE from inserted)<>(select NUMERO_SERIE_OBLIGATOIRE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'N° série obligatoire est ' + CASE WHEN NUMERO_SERIE_OBLIGATOIRE_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(BALANCE_ARTICLE) and (select BALANCE_ARTICLE from inserted)<>(select BALANCE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Pesé balance est ' + CASE WHEN BALANCE_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(GESTION_STOCK_BRF) and (select GESTION_STOCK_BRF from inserted)<>(select GESTION_STOCK_BRF from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Gestion stock par bon de réception est ' + CASE WHEN GESTION_STOCK_BRF = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(DROIT_CONSOMMATION_ACHAT_ARTICLE) and (select DROIT_CONSOMMATION_ACHAT_ARTICLE from inserted)<>(select DROIT_CONSOMMATION_ACHAT_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Droit consommation achat est ' + CASE WHEN DROIT_CONSOMMATION_ACHAT_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted


if UPDATE(DROIT_CONSOMMATION_VENTE_ARTICLE) and (select DROIT_CONSOMMATION_VENTE_ARTICLE from inserted)<>(select DROIT_CONSOMMATION_VENTE_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Droit consommation vente est ' + CASE WHEN DROIT_CONSOMMATION_VENTE_ARTICLE = 1 THEN 'activé' ELSE 'désactivé' END
from inserted

if UPDATE(TYPE_CALCUL) and (select TYPE_CALCUL from inserted)<>(select TYPE_CALCUL from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Type calcul est changé à : ' + TYPE_CALCUL
from inserted


if UPDATE(TYPE_DROIT_CONSOMMATION_ARTICLE) and (select TYPE_DROIT_CONSOMMATION_ARTICLE from inserted)<>(select TYPE_DROIT_CONSOMMATION_ARTICLE from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,
'Type droit consommation est changé à : ' + TYPE_DROIT_CONSOMMATION_ARTICLE
from inserted


if UPDATE(TVA_ARTICLE_ID) and 
							(select ISNULL(CONVERT(varchar(50),TVA_ARTICLE_ID),'') 'TVA_ARTICLE_ID' from inserted)
							<>
							(select ISNULL(CONVERT(varchar(50),TVA_ARTICLE_ID),'') 'TVA_ARTICLE_ID' from deleted)
insert ARTICLE_HISTORIQUE
(
ID_ARTICLE,
ID_SOCIETE,
ID_USER,
NOM_USER,
HISTORIQUE
)
select 
@ID,
@ID_SOCIETE,
@ID_USER,
@NOM_USER,

CASE WHEN TVA_ARTICLE_ID IS NULL THEN 'TAUX TVA est supprimé ' 
ELSE 'TAUX TVA est mis à jour à : ' + CAST(T.TAUX_TVA_ARTICLE as varchar(50))+' %' END AS HISTORIQUE
FROM inserted I

LEFT JOIN TVA_ARTICLE T ON (T.ID_TVA_ARTICLE=I.TVA_ARTICLE_ID)


END TRY

BEGIN CATCH  
	ROLLBACK TRANSACTION
	insert SQL_ERREUR (QUERY) values (@sql)
	select -99 as RESULTAT,ERROR_NUMBER() 
	RETURN
END CATCH;  

COMMIT TRANSACTION

END
GO
