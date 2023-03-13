#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

#DEFINE ENTER CHR(13)+CHR(10)

#DEFINE TIMESLEEP 1200


Static nHandURL := 0
Static nHandHTML := 0
Static oMeter, nAtual, nBmp, oText
Static nTotal, nMeterDif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ criaInt  บAutor  ณFabio Simonetti     บ Data ณ  27/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao Indigo PDV - Dados de vendedores				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndigoPDV - Gen - CRUD - CREATE                         	  บฑฑ

/*
HTTPSPost ( < cUrlPath>, 
		< cCertificate>, 
		< cPrivKey>, 
		< cPassPhrase>, 
		[ cGETParms], 
		[ cPOSTParms], 
		[ nTimeOut], 
		[ aHeadStr], 
		[ cHeaderRet] ) --> cReturn			


ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function criaNaInterface(cSessionToken,cEntidade, cJSONPar, lJob)
Local cHeadRet 		:= ""
Local aHeadOut  	:= defHeadOut(cSessionToken)
Local lCreated  	:= .F.
Local nTimeOut 		:= 120
Local cHeadRet 		:= ""
Local cRetHttpGet	:= ""
Local nTentativas 	:= MaxTentativas()
Local nVezes		:= 0

Private xRet := Nil
Private aaRet:= Nil

Default lJob	 := .F.

If Empty(cEntidade)
	If lJob    
		Conout("criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Else
		//
		Aviso("Aviso","criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
		Conout("criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Endif
Endif

cUrlPath := UrlEntidade(cEntidade)
//TODO
If Empty(cUrlPath)
	If lJob    
		Conout("criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Else
		//
		Aviso("Aviso","criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
		Conout("criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Endif
Endif

While !lCreated .And. !Empty(cUrlPath) .And. nVezes < nTentativas 
	xRet := HttpsPost(cUrlPath,"", "", "", 	"",	cJSONPar,nTimeOut,aHeadOut,@cHeadRet)
	
	If Type("xRet") == "C"
		aaRet := u_FromJson(xRet)
		
		//TODO VERIFICAR ; de ERRO
		If Type("aaRet") == "O"
			lCreated := .T.
		Else
			If lJob
				Conout("criaNaInterface - Erro tentativa de parsear item. Retorno: "+xRet+" JSON de saida: "+cJSONPar+" URL: "+StrTran(cUrlPath,"parse","indigoway"))
			Else
				//
				Aviso("Aviso","criaNaInterface - Erro tentativa de parsear item. Retorno: "+xRet+" JSON de saida: "+cJSONPar+" URL: "+StrTran(cUrlPath,"parse","indigoway"),{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
				Conout("criaNaInterface - Erro tentativa de parsear item. Retorno: "+xRet+" JSON de saida: "+cJSONPar+" URL: "+StrTran(cUrlPath,"parse","indigoway"))
				
			Endif
			nVezes++
		Endif
	Else
		If lJob
			Conout("criaNaInterface - Erro tentativa de criar item. URL: "+StrTran(cUrlPath,"parse","indigoway")+" JSON: "+cJSONPar)
		Else
			//
			Aviso("Aviso","criaNaInterface - Erro tentativa de criar item. URL: "+StrTran(cUrlPath,"parse","indigoway")+" JSON: "+cJSONPar,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
			Conout("criaNaInterface - Erro tentativa de criar item. URL: "+StrTran(cUrlPath,"parse","indigoway")+" JSON: "+cJSONPar)
		Endif
		nVezes++
	Endif
	Sleep(TIMESLEEP)
Enddo

Return aaRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ obtem    บAutor  ณFabio Simonetti     บ Data ณ  27/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao Indigo PDV - Dados de vendedores				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndigoPDV - Gen - GET		                         	  บฑฑ
				/*
				HTTPSGet ( < cUrl>, 
				< cCertifcate>, 
				< cPrivKey>, 
				< cPassPhrase>, 
				[ cGETParms], 
				[ nTimeOut], 
				[ aHeadStr], 
				[ @cHeaderRet] ) --> cReturn
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function obterNaInterface(cSessionToken,cEntidade, cObjId, lJob)
Local cHeadRet 		:= ""
Local aHeadOut  	:= defHeadOut(cSessionToken)
Local nTimeOut 		:= 120
Local cHeadRet 		:= ""
Local lObtained 	:= .F. 
Local nVezes		:= 0
Local nTentativas 	:= MaxTentativas()
Private xRet 		:= Nil
Private aaRet		:= Nil

Default cEntidade 		:= ""
Default cObjId	 		:= ""
Default lJob	 		:= .F.

cUrlPath := UrlEntidade(cEntidade)

If Empty(cUrlPath)
	If lJob
		Conout("obterNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Else
		//
		Aviso("Aviso","obterNaInterface - URL nใo mapeada para a entidade: "+cEntidade,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
		Conout("obterNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Endif
Endif

While !lObtained .And. !Empty(cUrlPath) .And. nVezes < nTentativas
	xRet := HttpsGet(cUrlPath+cObjId,"", "", "", '',120,aHeadOut,@cHeadRet)
	
	If Type("xRet") == "C"
		aaRet := u_FromJson(xRet)
		
		If Type("aaRet") == "O"
			lObtained := .T.
		Else
			cMsgErro := "obterNaInterface - Erro tentativa de parsear item. Retorno: "+xRet+" URL: "+StrTran(cUrlPath,"parse","indigoway")
			If lJob
				Conout(cMsgErro)
			Else
				//
				If Aviso("Aviso",cMsgErro,{"Novamente","Desistir"},3,"Aten็ใo:",,"BMPPERG") == 2
					nVezes := MaxTentativas()
				Endif
				Conout(cMsgErro)
			Endif
			nVezes++
		Endif
	Else
		cMsgErro := "obterNaInterface - Erro tentativa de obter item. URL: "+StrTran(cUrlPath,"parse","indigoway")+" Object: "+cObjId
		If lJob
			Conout(cMsgErro)
		Else
			//
			If Aviso("Aviso",cMsgErro,{"Novamente","Desistir"},3,"Aten็ใo:",,"BMPPERG") == 2
				nVezes := MaxTentativas()
			Endif
			Conout(cMsgErro)
		Endif
		nVezes++
	Endif
	Sleep(TIMESLEEP)
Enddo


Return aaRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ atualiza บAutor  ณFabio Simonetti     บ Data ณ  27/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao Indigo PDV - Dados de vendedores				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndigoPDV - Gen - GET		                         	  บฑฑ
				/*
				HTTPSGet ( < cUrl>, 
				< cCertifcate>, 
				< cPrivKey>, 
				< cPassPhrase>, 
				[ cGETParms], 
				[ nTimeOut], 
				[ aHeadStr], 
				[ @cHeaderRet] ) --> cReturn
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function xAtualizarNaInterface(cSessionToken, cEntidade, cObjId, aUpdFields, lJob)
Local cHeadRet 		:= ""
Local cCmd			:= ""
Local cUpdFields  	:= ""
Local lGet     		:= .F. 
Local lUpdated 		:= .F.
Local nTentativas 	:= MaxTentativas()
Local nVezes		:= 0
Local x				:= 0

Private xRet 		:= Nil
Private aaRet		:= Nil
Default cObjId	 	:= ""
Default lJob	 	:= .F.

cUrlPath := UrlEntidade(cEntidade)

cCmd := 'curl -X PUT -H "X-Parse-Application-Id: "'+aplicationKey()+'"'+;
							   ' -H "X-Parse-REST-API-Key: '+RESTKey()+'"'+;
							   ' -H "X-Parse-Session-Token: '+cSessionToken+'"'+;
							   ' -H "Content-Type: application/json"'
								
If Empty(cUrlPath)
	If lJob
		Conout("xAtualizarNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Else
		//
		Aviso("Aviso","xAtualizarNaInterface - URL nใo mapeada para a entidade: "+cEntidade,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
		Conout("xAtualizarNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Endif
Endif

//EX: ' -d "'+'
//{\"due_days_interval\":\"'+Alltrim(cCondPayment)+'\",\"description\":\"'+Alltrim(cDescPayment)+'\"}'+'" '+;
//{\"due_days_interval\":\"0,15,30,45,60,85\",\"description\":\"TESTE 6X\"\"}
For x := 1 To Len(aUpdFields)
	If x == 1
		cUpdFields := '{\'
	Endif

	cUpdFields += '"'+Alltrim(aUpdFields[x,1])+'\":'
	cUpdFields += '\"'+Alltrim(aUpdFields[x,2])+'\"'

	If x == Len(aUpdFields)
		cUpdFields += '}"'
	Else
		cUpdFields += ',\'
	Endif
Next
Conout("atualizaNaInterface cUpdFields: "+cUpdFields+" cUrlPath+cObjID: "+StrTran(UPPER(cUrlPath),"PARSE","indigoway")+cObjID)
cCmd := cCmd + ' -d "'+cUpdFields+ ' ' + cUrlPath+cObjID

While !lUpdated .And. nVezes < nTentativas .And. !Empty(cObjId)
	If lJob
		If !Empty(getCurlPath(lJob))
			WaitRunSrv( getCurlPath(lJob)+cCmd,;
			.F.,;
			StrTran(getCurlPath(),"\bin\","\bin"))
			Conout("atualizaNaInterface - Executando waitRunSrv cCmd: "+StrTran(cCmd,"Parse","Indigoway"))
		Endif
	Else				
		If !Empty(getCurlPath(lJob))
			winexec(cCmd,0)
			Conout("atualizaNaInterface - Executando winExec cCmd: "+StrTran(cCmd,"Parse","Indigoway"))
		Endif
	Endif
	// EX: If AllTrim(aaPaymentType:Get("due_days_interval")) == AllTrim(cCondPayment) .And. AllTrim(aaPaymentType:Get("description")) == AllTrim(cDescPayment)
	aaRet := u_obterNaInterface(cSessionToken,cEntidade, cObjId, lJob)
	
	For x := 1 To Len(aUpdFields)
		//If AllTrim(aaPaymentType:Get("due_days_interval")) == AllTrim(cCondPayment)
		If Alltrim(aaRet:Get(aUpdFields[x,1])) != Alltrim(aUpdFields[x,2])
			Exit
		Endif
	Next
	
	If x > Len(aUpdFields)
		lUpdated := .T.
		Conout("atualizaNaInterface - Item atualizado! ")
	Else	
		Conout("atualizaNaInterface - Item Nใo atualizado, mais uma tentativa ")
		nVezes++
	Endif
	Sleep(TIMESLEEP)
Enddo

Return aaRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ atualiza บAutor  ณFabio Simonetti     บ Data ณ  01/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao Indigo PDV - Excluir dados da interface         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndigoPDV 												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function excluiNaInterface(cSessionToken, cEntidade, cObjId, lJob)
Local lDeleted 		:= .F.
Local cUrlPath 		:= ""
Local nTentativas 	:= MaxTentativas()
Local nVezes		:= 0

cUrlPath := UrlEntidade(cEntidade)

While !lDeleted .And. nVezes < nTentativas .And. !Empty(cObjId)

	cCmd := 'curl -X DELETE -H "X-Parse-Application-Id: '+aplicationKey()+'" '+;
							   ' -H "X-Parse-REST-API-Key: '+RESTKey()+'" '+;
   							   ' -H "X-Parse-Session-Token: '+cSessionToken+'" '+;
							   cUrlPath + cObjId
	If lJob
		If !Empty(getCurlPath(lJob))
			WaitRunSrv( getCurlPath(lJob)+cCmd,;
			.F.,;
			StrTran(getCurlPath(lJob),"\bin\","\bin"))
			Conout("excluiNaInterface - Executando waitRunSrv cCmd: "+StrTran(cCmd,"Parse","Indigoway"))
		Endif
	Else				
		If !Empty(getCurlPath(lJob))
			winexec(cCmd,0)
			Conout("excluiNaInterface - Executando winExec cCmd: "+StrTran(cCmd,"Parse","Indigoway"))
		Endif
	Endif
	// EX: If AllTrim(aaPaymentType:Get("due_days_interval")) == AllTrim(cCondPayment) .And. AllTrim(aaPaymentType:Get("description")) == AllTrim(cDescPayment)
	aaRet := u_obterNaInterface(cSessionToken, cEntidade, cObjId, lJob)
	
	//TODO TESTES
	If aaRet:Get("code") == 101
		lDeleted := .T.
		Conout("excluiNaInterface - Objeto excluํdo! Entidade: "+cEntidade+" Obj: "+cObjId)
	Else 
		Conout("excluiNaInterface - Objeto Nใo excluํdo! Entidade: "+cEntidade+" Obj: "+cObjId)
		Conout("Tentando novamente")
		nVezes++
	Endif
	Sleep(TIMESLEEP)
Enddo

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ obtem    บAutor  ณFabio Simonetti     บ Data ณ  27/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao Indigo PDV - Dados de vendedores				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IndigoPDV - Gen - GET		                         	  บฑฑ
				/*
				HTTPSGet ( < cUrl>, 
				< cCertifcate>, 
				< cPrivKey>,              `
				< cPassPhrase>, 
				[ cGETParms], 
				[ nTimeOut], 
				[ aHeadStr], 
				[ @cHeaderRet] ) --> cReturn
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function queryNaInterface(cSessionToken, cEntidade, aQryFields, lJob)
Local cHeadRet 		:= ""
Local aHeadOut  	:= defHeadOut(cSessionToken)
Local nTimeOut 		:= 120
Local cHeadRet 		:= ""
Local lObtained 	:= .F. 
Local nVezes		:= 0
Local nTentativas 	:= MaxTentativas()
Local cQryJson		:= ""
Local cCont			:= 0
Private xRet 		:= Nil
Private aaRet		:= Nil

Default cEntidade 		:= ""
Default lJob	 		:= .F.

cUrlPath := UrlEntidade(cEntidade)

If Empty(cUrlPath)
	If lJob
		Conout("obterNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Else
		//
		Aviso("Aviso","criaNaInterface - URL nใo mapeada para a entidade: "+cEntidade,{"Tentar novamente"},3,"Aten็ใo:",,"BMPPERG")	
		Conout("obterNaInterface - URL nใo mapeada para a entidade: "+cEntidade)
	Endif
Endif


For nCont := 1 To Len(aQryFields)
    If nCont == 1
    	cQryJson += "where={"
    Endif
	
	If aQryFields[nCont,3] //Like Operator
		//{"company_id":{"$regex":"^02"}}
		cQryJson += '"'+aQryFields[nCont,1]+'":{"$regex":"^'+AllTrim(aQryFields[nCont,2])+'"}'
	Else
		cQryJson += '"'+aQryFields[nCont,1]+'":"'+AllTrim(aQryFields[nCont,2])+'"'
	Endif
	
	If nCont == Len(aQryFields)
		cQryJson += '}'
	Else
		cQryJson += ','
	Endif	
Next

//aaOrdersAvailable := u_FromJson(HttpsGet("https://api.parse.com/1/classes/order_head/","", "", "", 'where={"sync_status":"1"}',120,aHeadOut,@cHeadRet))
While !lObtained .And. !Empty(cUrlPath) .And. nVezes < nTentativas
	xRet := HttpsGet(cUrlPath,"", "", "", cQryJson,120,aHeadOut,@cHeadRet)

	If Type("xRet") == "C"
		aaRet := u_FromJson(xRet)
		
		If Type("aaRet") == "O"
			lObtained := .T.
		Else
			cMsgErro := "obterNaInterface - Erro tentativa de parsear item. Retorno: "+xRet+" URL: "+StrTran(cUrlPath,"parse","indigoway")
			If lJob
				Conout(cMsgErro)
			Else
				//
				If Aviso("Aviso",cMsgErro,{"Novamente","Desistir"},3,"Aten็ใo:",,"BMPPERG") == 2
					nVezes := MaxTentativas()
				Endif
				Conout(cMsgErro)
			Endif
			nVezes++
		Endif
	Else
		cMsgErro := "obterNaInterface - Erro tentativa de criar item. URL: "+cUrlPath
		If lJob
			Conout(cMsgErro)
		Else
			//
			If Aviso("Aviso",cMsgErro,{"Novamente","Desistir"},3,"Aten็ใo:",,"BMPPERG") == 2
				nVezes := MaxTentativas()
			Endif
			Conout(cMsgErro)
		Endif
		nVezes++
	Endif
	Sleep(TIMESLEEP)
Enddo


Return aaRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetToken      บAutor  ณFabio Simonetti     บ Data ณ  05/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento Indigo                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GetToken()
Local cUrlPath := {}
Local aHeadOut := {}
Local cUserPar := GetMV("PDV_PDVUSR",,"protheus")
Local cPassPar := GetMV("PDV_PDVPAS",,"ahsbASDNasd")
Local cUrlPath := ""
Local cSession := ""
Local cHeadRet := ""

aAdd(aHeadOut,"X-Parse-Application-Id: "+AplicationKey())
aAdd(aHeadOut,"X-Parse-REST-API-Key: "+RESTKey())

cUrlPath := "https://api.parse.com/1/login?username="+AllTrim(cUserPar)+"&password="+AllTrim(cPassPar)

aaUser := u_FromJson(HttpsGet(cUrlPath,"", "", "", "",120,aHeadOut,@cHeadRet))

If ValType(aaUser:Get("sessionToken")) == "U"
	Conout("Erro de Login - Code: "+cValTochar(aaUser:Get("code"))+" - Error: "+aaUser:Get("error"))
	cSession := ""
Else
	Conout("SessionToken: "+aaUser:Get("sessionToken"))
	cSession := aaUser:Get("sessionToken")
Endif

Return cSession

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIndigoProcess บAutor  ณFabio Simonetti     บ Data ณ  22/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento Indigo                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function UrlEntidade(cEntidade)
Local cUrlPath := ""

If cEntidade == "LOG"
	cUrlPath := "https://api.parse.com/1/login"
ElseIf cEntidade == "SE4"
	cUrlPath := "https://api.parse.com/1/classes/payment_type/"
ElseIf cEntidade == "SC5"
	cUrlPath := "https://api.parse.com/1/classes/order_head/"
ElseIf cEntidade == "SC6"
	cUrlPath := "https://api.parse.com/1/classes/order_item/"
Elseif cEntidade == "SB1"
	cUrlPath := "https://api.parse.com/1/classes/product/"
Elseif cEntidade == "SA1"
	cUrlPath := "https://api.parse.com/1/classes/customer/"
Elseif cEntidade == "SA3"
	cUrlPath := "https://api.parse.com/1/users/"
Elseif cEntidade == "SX52"
	cUrlPath := "https://api.parse.com/1/classes/segment"
Elseif cEntidade == "SX53"
	cUrlPath := "https://api.parse.com/1/classes/br_states"
Elseif cEntidade == "SX5A2"
	cUrlPath := "https://api.parse.com/1/classes/region"
Endif

Return cUrlPath
               
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdefHeadOut    บAutor  ณFabio Simonetti     บ Data ณ  01/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicoes de cabecalho de requisicao							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function defHeadOut(cSessionToken)
Local aHeadOut := {}

aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
aadd(aHeadOut,"Content-Type: application/json")
aAdd(aHeadOut,"X-Parse-Application-Id: "+AplicationKey())
aAdd(aHeadOut,"X-Parse-REST-API-Key: "+RESTKey())
aAdd(aHeadOut,"X-Parse-Session-Token: "+cSessionToken)

Return aHeadOut
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaxTentativas บAutor  ณFabio Simonetti     บ Data ณ  01/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicoes de cabecalho de requisicao							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MaxTentativas()
Local nTentativas := GetMV("IP_TENTIV",,3) 
Return nTentativas
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaxTentativas บAutor  ณFabio Simonetti     บ Data ณ  01/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicoes de cabecalho de requisicao							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function verifyInternet(lJob)
Local cHeadRet	  := ""
Local cRetHttpGet := ""
Local lRet		  := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida conexao de internet			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cRetHttpGet := HttpGet("www.apple.com","",90,{},@cHeadRet)

If !("200 OK" $ cHeadRet)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Realiza mais teste com o google		ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cRetHttpGet := HttpGet("www.google.com","",90,{},@cHeadRet)
	
	If !("200 OK" $ cHeadRet)
		If lJob    
			Conout("verifyInternet - sem conexใo de internet")
		Else
			Aviso("Aviso","verifyInternet - sem conexใo de internet",{"Sair"},3,"Aten็ใo:",,"BMPPERG")	
			Conout("verifyInternet - sem conexao de internet")
		Endif
        lRet := .F.
	Endif
Endif
 
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetCurlPath   บAutor  ณFabio Simonetti     บ Data ณ  27/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicoes de cabecalho de requisicao							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function getCurlPath(lJob)
Local cPath := ""
Local lContinua := .T. 
Local nOpcao := 2
Local cCurlPath		:= GetMV("PDV_CURL1",,"C:\Program Files (x86)\cURL\bin\curl.exe")
Local cCurlAux		:= GetMV("PDV_CURL2",,"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\curl.exe")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o Path						ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If File(cCurlPath)
	cPath := StrTran(cCurlPath,"curl.exe","")
Else
	If File(cCurlAux)
		cPath := StrTran(cCurlAux,"curl.exe","")
	Endif
Endif
                                                                                   
While lContinua
	If Empty(cPath)
		If lJob
			Conout("getCurlPath - Nใo encontrado curl.exe! Caminhos verificados: "+GetMV("PDV_CURL1",,"C:\Program Files (x86)\cURL\bin\curl.exe")+" e "+GetMV("PDV_CURL2",,"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\curl.exe"))
		Else
			nOpcao := Aviso("Aviso","getCurlPath - Nใo encontrado curl.exe! Caminhos verificados: "+;
				GetMV("PDV_CURL1",,"C:\Program Files (x86)\cURL\bin\curl.exe")+;
				" e "+GetMV("PDV_CURL2",,"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\curl.exe") ,{"Tentar novamente","Sair"},;
				3,"Aten็ใo:",,"BMPPERG")
		Endif
	Endif
	
	If !Empty(cPath) .Or. (Empty(cPath) .And. nOpcao == 2)
		lContinua := .F.
	Endif
Enddo

Return cPath
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaplicationKey บAutor  ณFabio Simonetti     บ Data ณ  27/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChave de aplicacao											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function aplicationKey()
Local cRet := "<your parse Application Id>"
Return cRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRESTKey       บAutor  ณFabio Simonetti     บ Data ณ  27/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChave de REST API 											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RESTKey()
Local cRet := "<your REST parse API KEY>"
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIndigoProcess บAutor  ณFabio Simonetti     บ Data ณ  22/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessamento Indigo                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function IndProcess( bAction, cTitle ,cMsg,lAbort)

Local oDlg, oTimer, oBMP
Local lEnd := .f.
Local nVal := 0
Local aSaves := {}
Local cSepPasta     := If(IsSrvUnix() .And. GetRemoteType() == 1,"/","\")

AADD(aSaves,oMeter)
AADD(aSaves,nAtual)
AADD(aSaves,nBMP)
AADD(aSaves,otext)
AADD(aSaves,nTotal)
AADD(aSaves,nMeterDif)

nAtual:= 0
nMeterDif:= 0

DEFAULT bAction := { || nil }, cMsg := "Processando...", cTitle := "Aguarde" //
DEFAULT lAbort := .f.

If cVersao == "10"
	DEFINE MSDIALOG oDlg FROM 0,0 TO 160,300 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL
	
	TBitmap():New(05,40,100,100,,GetSrvProfString("Startpath","")+"indigo\indigo.png",.T.,oDlg,,,,.F.,,,,,.T.)
	
	@ 35,10 SAY oText VAR cMsg SIZE 135,10 OF oDlg FONT oDlg:oFont PIXEL
	@ 45,10 METER oMeter VAR nVal TOTAL 10 SIZE 143, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL
	IF lAbort
		DEFINE SBUTTON FROM 66,120 TYPE 2 ACTION (lAbortPrint := .t.,lEnd := .t.) ENABLE OF oDlg PIXEL
	Else
		DEFINE SBUTTON FROM 66,120 TYPE 2 OF oDlg PIXEL
	Endif
	oDlg:bStart:= { || Eval( bAction, @lEnd ),lEnd := .t., oDlg:End() }
	ACTIVATE DIALOG oDlg VALID lEnd CENTERED
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,300 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL
	
	TBitmap():New(05,40,100,100,,GetSrvProfString("Startpath","")+"indigo\indigo.png",.T.,oDlg,,,,.F.,,,,,.T.)
	
	@ 40,10 SAY oText VAR cMsg SIZE 135,10 OF oDlg FONT oDlg:oFont PIXEL
	@ 50,10 METER oMeter VAR nVal TOTAL 10 SIZE 130, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL
	IF lAbort
		DEFINE SBUTTON FROM 64,120 TYPE 2 ACTION (lAbortPrint := .t.,lEnd := .t.) ENABLE OF oDlg PIXEL
	Else
		DEFINE SBUTTON FROM 64,120 TYPE 2 OF oDlg PIXEL
	Endif
	oDlg:bStart:= { || Eval( bAction, @lEnd ),lEnd := .t., oDlg:End() }
	ACTIVATE DIALOG oDlg VALID lEnd CENTERED
Endif
oMeter := aSaves[1]
nAtual := aSaves[2]
nBMP := aSaves[3]
oText := aSaves[4]
nTotal := aSaves[5]
nMeterDif := aSaves[6]
Return nil
//-----------------------------------------------------------------------//
User Function IndigoReg(nTot)

nTotal:= nTot

if nTotal<100
	oMeter:nTotal:= nTotal
	nMeterDif:= 1
else
	oMeter:nTotal:= 25
	nMeterDif:= (oMeter:nTotal) / nTotal
endif

nAtual := 0

Return nil

//-----------------------------------------------------------------------//
User Function IndigoPrc(cMsg)

Default cMsg := ""
// implementa็ao interna (c++) da IncProc ...
IntIncProc( cMsg )
return NIL