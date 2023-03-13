#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

#DEFINE ENTER CHR(13)+CHR(10)
Static nHandURL := 0
Static nHandHTML := 0
Static oMeter, nAtual, nBmp, oText
Static nTotal, nMeterDif

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RPDVJ03  �Autor  �Fabio Simonetti     � Data �  26/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Dados de vendedores				  ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ03(aParam) 
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
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SA3"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Vendedores/Usu�rios - (RPDVJ03) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Vendedores/Usu�rios - (RPDVJ03) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es de Vendedores/Usu�rios do Protheus (RPDVJ03) ==> " ))
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
��� RdMake   �		    � Autor � Fabio Simonetti       � Data � 10/09/13 ���
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
Local nRegTot	:= 0
Local nReg		:= 0
Local cPDVUsername := ""
Local cPDVPassword := ""
Local cPDVEmail    := ""
Local cCodSeller   := ""
Local aHeadOut 	   := {}
lOCAL aUpdFields   := {} 
Local cParPost 	:= ""
Local aHeadOut 	:= {}
Local cHeadRet 	:= ""
Public Inclui  := .T.

//���������������������������������Ŀ
//� Verifica conexao de internet	�
//�����������������������������������
If !u_verifyInternet(lJob)
	Return
Endif

//��������������������������������������������������������Ŀ
//� Abre tabela de estados								   �
//����������������������������������������������������������
dbSelectarea("SX5")
SX5->(dbSeek(xFilial("SX5")+"12"))

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
cQuery := "SELECT R_E_C_N_O_ SA3REC, D_E_L_E_T_ DEL, A3_PDVID PDVID " + ENTER
cQuery += "FROM "+RetSQLName("SA3")+" SA3 " + ENTER
cQuery += "WHERE A3_FILIAL = '"+xFilial("SA3")+"' " + ENTER
cQuery += "AND A3_PDVSINC = 'S' " + ENTER
cQuery += "AND A3_MSEXP = '' " + ENTER

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SA3")
SA3->(dbSetOrder(1)) //A3_FILIAL + A3_CODIGO

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

cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ01")
	Else	
		Aviso("Aviso","N�o foi possivel obter o SessionToken para comunica��o com o Mobile.",{"Ok"},2)
	EndIf
EndIf

U_IndigoReg(nRegTot)

QRY->(dbGoTop())
While QRY->(!Eof())
	//��������������������������������������������������������Ŀ
	//� Verifica o Status									   �
	//����������������������������������������������������������
	nReg++
	If !lJob
		U_IndigoPrc("Processando: "+cValToChar(nReg)+"/"+cValTochar(nRegTot))
	Else
		Conout("Processando: "+cValToChar(nReg)+"/"+cValTochar(nRegTot))
    Endif
	If !Empty(QRY->DEL)
		//DELETE
		u_excluiNaInterface(cSessionToken, "SA3",AllTrim(QRY->PDVID))
		
		cSQL := "UPDATE "+RetSQLName("SA3")+" "
		cSQL += "SET A3_MSEXP = 'X', A3_PDVLOG = '"+DtoS(dDataBase)+" - "+Time()+"' "
		cSQL += "WHERE A3_PDVID = '"+Alltrim(QRY->PDVID)+"' "
		
		TcSqlExec(cSQL)
	Else
		SA3->(dbGoTo(QRY->SA3REC))
		
		//indentifica como um post ou update
		lUpdate			:= .F.
		
		//Controle se foi realizado o update
		lUpdated     := .F.
		
		cPDVUsername := AllTrim(SA3->A3_EMAIL)
		cPDVPassword := "indigo1234"
		cPDVEmail    := AllTrim(SA3->A3_EMAIL)
		cSellerName  := Capital(SA3->A3_NOME)
		cCodSeller   := SA3->A3_COD
		
		If !Empty(SA3->A3_PDVLOG)
			//��������������������������������������������������������Ŀ
			//� Verifica os campos alterados						   �
			//����������������������������������������������������������
			aaUser := u_obterNaInterface(cSessionToken, "SA3", AllTrim(SA3->A3_PDVID), lJob)
			
			If AllTrim(aaUser:Get("username")) != cPDVUsername 
				lUpdate := .T.
			Endif
			
			If AllTrim(aaUser:Get("email")) != cPDVEmail
				lUpdate := .T.
			Endif
			
			If AllTrim(aaUser:Get("seller_name")) != cSellerName
				lUpdate := .T.
			Endif
			
			If AllTrim(aaUser:Get("seller_id")) != cCodSeller
				lUpdate := .T.
			Endif
			
			//UPDATE   
			If lUpdate
				aUpdFields := {}
			 	aAdd(aUpdFields,{"username",cPDVUsername})
			 	aAdd(aUpdFields,{"email",cPDVEmail})
			 	aAdd(aUpdFields,{"seller_name",cSellerName})
			 	aAdd(aUpdFields,{"seller_id",cCodSeller})

			 	//u_xAtualizarNaInterface("SA3", AllTrim(SA3->A3_PDVID), aUpdFields, lJob)
			 	Conout("Atualizar vendedores/usu�rios - Backlog")
			 	
			 	
				SA3->(RecLock("SA3",.F.))
					SA3->A3_MSEXP  := DtoS(dDataBase)+" - "+Time()
					SA3->A3_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SA3->(MsUnlock())
			Else
				//����������������������������������������������������������Ŀ
				//� sem nenhum campo importante foi alterado apenas atualiza �
				//������������������������������������������������������������
				SA3->(RecLock("SA3",.F.))
					SA3->A3_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SA3->(MsUnlock())
			Endif	
		Else
			//CREATE                         
			aaUser := u_criaNaInterface(cSessionToken, "SA3",;
				'{"username":"'+cPDVUsername+'","email":"'+cPDVEmail+'","password":"'+cPDVPassword+'","seller_name":"'+cSellerName+'","seller_id":"'+cCodSeller+'"}',;
				lJob)
			
			SA3->(RecLock("SA3",.F.))
				SA3->A3_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SA3->A3_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SA3->A3_PDVID  := aaUser:Get("objectId")
			SA3->(MsUnlock())
		Endif
	Endif

	QRY->(dbSkip())
Enddo

MsgInfo("T�rmino do processamento, total de itens processados: "+cValTochar(nRegTot))

Return