#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

#DEFINE ENTER CHR(13)+CHR(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RPDVJ02  �Autor  �Fabio Simonetti     � Data �  26/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Envio de segmentos				  ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ02(aParam) 
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local nOpca          := 0
Local aSays          := {}
Local aButtons       := {}
Local aArea          := {}
Private lJob         := .F.
Default aParam       := {.F.}

//���������������������������������������������������������������������Ŀ
//� Determina a execucao via job                                        �
//�����������������������������������������������������������������������
lJob := aParam[1]

//���������������������������������������������������������������������Ŀ
//� Prepara o ambiente dependendo do modo de execucao                   �
//�����������������������������������������������������������������������
If lJob
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SE4"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Condi��o de pagamento - (RPDVJ02) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Condi��o de pagamento - (RPDVJ02) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es de condi��o de pagamento do Protheus (RPDVJ02) ==> " ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( "IndigoPDV - Condi��o de pagamento", aSays, aButtons )
Endif
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� RdMake   �CallEMails� Autor � Fabio Simonetti       � Data � 10/09/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PDVInterface()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
If lJob        
     procPDV()
Else
     U_IndProcess({|| procPDV() },"Processando...")
Endif
Return
/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Program   �PDVInterface �Author �Fabio Simonetti     � Date �  17/04/14   ���
����������������������������������������������������������������������������͹��
���Desc.     � Funcoes comuns e genericas de utilizacao dos portais          ���
����������������������������������������������������������������������������͹��
���Data      � Funcionalidade alterada ou incluida                           ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static function procPDV()
Local aHeadOut 	:= {}
Local cParPost 	:= ""
Local aHeadOut 	:= {}
Local cHeadRet 	:= ""
Local sGetRet  	:= ""
Local cQuery	:= ""
Local nRegTot	:= 0
Local nReg		:= 0
Local lUpdate 	 := .F.
Local cIDPayment   := ""
Local cCondPayment := ""
Local cDescPayment := ""

Local lErro     := .T.
Local lGravaOk	:= .F.

aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
aadd(aHeadOut,"Content-Type: application/json")
aAdd(aHeadOut,"X-Parse-Application-Id: <Parse-Application-Id>")
aAdd(aHeadOut,"X-Parse-REST-API-Key: <Parse-REST-API-Key>")

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
cQuery := "SELECT R_E_C_N_O_ SE4REC, D_E_L_E_T_ DEL, E4_PDVID PDVID " + ENTER
cQuery += "FROM "+RetSQLName("SE4")+" SE4 " + ENTER
cQuery += "WHERE E4_FILIAL = '"+xFilial("SE4")+"' " + ENTER
cQuery += "AND E4_PDVSINC = 'S' " + ENTER
cQuery += "AND E4_MSEXP = '' " + ENTER

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SE4")
SE4->(dbSetOrder(1)) //E4_FILIAL + E4_CODIGO

//�����������������������������������������Ŀ
//� Execute the main query					�
//�������������������������������������������
If Select("QRY") > 0
	DbSelectArea("QRY")
	DbCloseArea()
EndIf
TcQuery cQuery New Alias "QRY"

While QRY->(!Eof())
	nRegTot++
	QRY->(dbSkip())
Enddo

If nRegTot == 0
	If lJob
		Conout("Sem registros aptos para integrar")
	Else
		MsgAlert("Sem registros aptos para integrar")	
	Endif
	Return
Endif

U_IndigoReg(nRegTot)

QRY->(dbGoTop())
While QRY->(!Eof())
	If !Empty(QRY->DEL)
		//DELETE
		cCmd := 'curl -X DELETE -H "X-Parse-Application-Id: <Parse-Application-Id>"'+;
									   ' -H "X-Parse-REST-API-Key: <Parse-REST-API-Key>"'+;
									   ' https://api.parse.com/1/classes/payment_type/'+AllTrim(QRY->PDVID)
		
		If lJob	   
			WaitRunSrv( "C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\"+cCmd,;
			.F.,;
			"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin")
		Else				
			winexec(cCmd,0)
		Endif
		
		SE4->(RecLock("SE4",.F.))
			SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
			SE4->E4_PDVLOG := DtoS(dDataBase)+" - "+Time()
		SE4->(MsUnlock())
	Else
		SE4->(dbGoTo(QRY->SE4REC))
		
		//indentifica como um post ou update
		lUpdate			:= .F.
		
		//Controle se foi realizado o update
		lUpdated		:= .F.
	    cIDPayment   	:= SE4->E4_CODIGO
		cCondPayment 	:= SE4->E4_COND
		cDescPayment 	:= SE4->E4_DESCRI
		
		If !Empty(SE4->E4_PDVLOG)
			//��������������������������������������������������������Ŀ
			//� Verifica os campos alterados						   �
			//����������������������������������������������������������
			aaPaymentType := u_FromJson(HttpsGet("https://api.parse.com/1/classes/payment_type/"+AllTrim(SE4->E4_PDVID),"", "", "", '',120,aHeadOut,@cHeadRet))
			
			//TODO - TESTAR
			If AllTrim(aaPaymentType:Get("due_days_interval")) != cCondPayment 
				lUpdate := .T.
			Endif
			
			If AllTrim(aaPaymentType:Get("description")) != cDescPayment
				lUpdate := .T.
			Endif
			
			//UPDATE   
			If lUpdate
			 	cCmd := 'curl -X PUT -H "X-Parse-Application-Id: <Parse-Application-Id>"'+;
							   ' -H "X-Parse-REST-API-Key: <Parse-REST-API-Key>"'+;
							   ' -H "Content-Type: application/json"'+;
							   ' -d "'+'{\"due_days_interval\":\"'+Alltrim(cCondPayment)+'\",\"description\":\"'+Alltrim(cDescPayment)+'\"}'+'" '+;
							   ' https://api.parse.com/1/classes/payment_type/'+AllTrim(SE4->E4_PDVID)
				While !lUpdated 
					If lJob	   
						WaitRunSrv( "C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\"+cCmd,;
						.F.,;
						"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin")
					Else				
						winexec(cCmd,0)
					Endif
					//��������������������������������������������������������Ŀ
					//� Verifica o Status se foi alterado					   �
					//����������������������������������������������������������
					aaPaymentType := u_FromJson(HttpsGet("https://api.parse.com/1/classes/payment_type/"+AllTrim(SE4->E4_PDVID),"", "", "", '',120,aHeadOut,@cHeadRet))
							
					If AllTrim(aaPaymentType:Get("due_days_interval")) == AllTrim(cCondPayment) .And. AllTrim(aaPaymentType:Get("description")) == AllTrim(cDescPayment)
						lUpdated := .T.
						If lJob	
							Conout("IndigoPDV - Condi��o de pagamento atualizada com sucesso! "+cIDPayment)
						Endif 
						SE4->(RecLock("SE4",.F.))
							SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
							SE4->E4_PDVLOG := DtoS(dDataBase)+" - "+Time()
						SE4->(MsUnlock())
					Else
						//��������������������������������������������������������Ŀ
						//� espera talvez problema de oscilacao					   �
						//����������������������������������������������������������
						Sleep(1500)	
						If lJob	
							Conout("IndigoPDV - Condi��o de pagamento n�o atualizada... "+cIDPayment)
						Endif
					Endif
				Enddo	
			Endif	
		Else
			//POST
			aaPaymentType := u_FromJson(HttpsPost("https://api.parse.com/1/classes/payment_type/","", "", "", "", '{"payment_id":"'+cIDPayment+'","due_days_interval":"'+cCondPayment+'","description":"'+cDescPayment+'"}',120,aHeadOut,@cHeadRet))
			
			SE4->(RecLock("SE4",.F.))
				SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SE4->E4_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SE4->E4_PDVID  := aaPaymentType:Get("objectId")
				
			SE4->(MsUnlock())
		Endif
	Endif

	QRY->(dbSkip())
Enddo

Return