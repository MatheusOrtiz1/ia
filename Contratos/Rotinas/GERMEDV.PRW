#INCLUDE "protheus.ch"    
#include "fileio.ch"                                                                                
#include "rwmake.ch"  
#INCLUDE "FWMVCDEF.CH"                                                          

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | GERMEDV   	  ³Autor ³ Adriao Guedes           |Data ³ 02/04/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Importacao de Planilha para gerar Medições                       ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Conasa                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

User Function GERMEDV() 
Local cLocArq   := ""
    
    Private _cPerg := "GERMEDV" 

    if !Pergunte(_cPerg,.T.)
        MsgAlert("Abortada pelo usuário.") ; Return( Nil )
    Endif   

    cLocArq := MV_PAR01 
     IF MsgYesNo( "Deseja incluir as Medições ?","MEDICAO CONTRATO")
   		FWMsgRun(, {|| ProcImp(cLocArq) }, 'Por Favor Aguarde...') 
   	 EndiF
Return( Nil )     


/*-------------------------------------------------------------------------------------------------
//Procesa archivo ...
-------------------------------------------------------------------------------------------------*/
Static Function ProcImp( cFile )   

Local nTamArq
Local cLinha := ""
Local aDeta  := {} // Detalhes das linhas da medicao
Local nF
Local nE
Local cCompet
Local aLog := {}
Local cContra 
Local oModel    := Nil
Local cNumMed   := ""
Local aMsgDeErro:= {}
Local aCompets  := {}
Local nPosCtr   := 0
Local lprod     := .T.
Local nSpace    := 0
Local lCtrPrd   := GETMV( "CN_CTRPRD" )

Private cFalha  := "" 
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.


    if !File( cFile )
        MsgAlert("Arquivo não localizado ou inexistente.") ; Return( Nil )
    Endif
                
    FT_FUSE( cFile ) ;  nTamArq := FT_FLastRec() ; FT_FGOTOP( )
    // Faz o processamento do arquivo
    While !FT_FEOF( )
        if !Empty( cLinha := FT_FREADLN() )
            AADD(aDeta,StrTokArr2(cLinha,";",.T.))  
        Endif
        FT_FSKIP()
    End While  

    aDel( aDeta , 1) ; aSize( aDeta , Len(aDeta) -1 )
    if Len( aDeta ) <= 0
        MsgAlert("Não existe itens no arquivo selecionado.")
        Return( Nil ) 
    Endif

    If MSGYESNO("Deseja gerar as medições da Planilha ?","MEDICOES DE CONTRATOS")
	
		cContra := Alltrim(aDeta[2,1]) //StrZero( Val(aDeta[2,1]),15,0)  // DADOS DO CONTRATO POSICAO [2] [1]
	    
        
        // FAZ TRATAMENTO DO NUMERO DO CONTRATO QUE PODE VARIAR
        If Len(Alltrim(cContra)) < 8
                                                    // cod.ano
            // padrao de numeros de contratos Conasa   999.9999
            nPosCtr := At('.',cContra)
            cContra := StrZero(Val(SUBSTR( cContra, 1 , nPosCtr-1)),3) + Alltrim(Substr(cContra,nPosCtr,20))
            
        EndIf       
        //-------------------------------------------------------
        // Verifica se tem produto invalido na planilha
        //-------------------------------------------------------
        nSpace := 15-(len(Alltrim(cContra)))
        
        If lCtrPrd
            For nE := 1 to Len(aDeta)
                DbSelectArea("ZA4")
                DbSetOrder(1)
                If !ZA4->(DBSEEK(xFilial("ZA4")+cContra+Space(nSpace)+Alltrim(aDeta[nE,5])))
                    lProd := .F.
                    aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","PRODUTO : "+Alltrim(aDeta[nE,5])+" NAO PERMITIDO",cFile})
                EndIf
            Next nE
        Else 
           lProd := .T.
        EndIf     
                 

        DbSelectArea("CN9")
	    DbSetOrder(1)
	    If  CN9->(DbSeek(xFilial("CN9")+  cContra  )) .And. lProd
		
            // Busca a competencia ref ao dia de eexxcução da planilha
		    aCompets := CtrCompets() // Busca as competencias no array retornado pela função CtrCompets
		    cCompet  := aDeta[2,3]   //Substr(DToS(DDATABASE),5,2)+"/"+Substr(DToS(DDATABASE),1,4) POSICAO [2] [2]
		    nCompet  := aScan(aCompets, {|x| AllTrim(x) == cCompet }) 
		    //--------------------------------------------------------------------------------------------

		    oModel := FWLoadModel("CNTA121")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            If(oModel:CanActivate())           
                oModel:Activate()
                oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
                oModel:SetValue("CNDMASTER","CND_RCCOMP"    ,cValToChar(nCompet)) //Selecionar competência
            
                // Seleciona Planilha 2 ref a planlha sem items para medição
                oModel:GetModel("CXNDETAIL"):GoLine(val(aDeta[2,2])) //Marca planilha selecionada no array da planilha de medicao
                oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.) //Marcar a planilha(nesse caso apenas uma)

		        // percorre array das medições
                // uniq.Key CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_NUMERO+CNE_ITEM                                                                                                                                                                                           
		        For nF := 1 To Len(aDeta)     
                    // Aiciona um item a planilha
                    oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(cValTochar(aDeta[nF,4]), CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha 
                   			
			        oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT'	, aDeta[nF,5] )         // PRODUTO
			        oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' 	, VAL(aDeta[nF,6]) )    // QUANTIDADE
			        oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , VAL(aDeta[nF,7]) )    // VALOR UNIT
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_CC'     , aDeta[nF,08]     )    // CENTRO CUSTO
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_ITEMCT' , aDeta[nF,09]     )    // IMTEM CONTABIL
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_CLVL'   , aDeta[nF,10]     )    // CLASSE VALOR
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_UNATUR' , aDeta[nF,11]     )    // NATUREZA
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_UOBS'   , aDeta[nF,12]     )    // OBSERVACAO
             
                    
                    if nF < Len( aDeta  )
                        oModel:GetModel('CNEDETAIL'):AddLine()
                    Endif
                    
                Next nF 
                //-----------------------------------------------------------------------
                If (oModel:VldData()) /*Valida o modelo como um todo*/
                    oModel:CommitData()
                EndIf
    	   EndIf	 
        Else 
            aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","CONTRATO NAO ENCONTRADO",cFile})
            GExpExcel(aLog)
            Return(Nil)
        EndIf
         
        If(oModel:HasErrorMessage())
            aMsgDeErro := oModel:GetErrorMessage()
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 1 : "+aMsgDeErro[1],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 2 : "+aMsgDeErro[2],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 3 : "+aMsgDeErro[3],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 4 : "+aMsgDeErro[4],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 5 : "+aMsgDeErro[5],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 6 : "+aMsgDeErro[6],cFile})
			aadd(aLog,{"CONTRATO",aDeta[2][1],"FALHA","FALHA 7 : "+aMsgDeErro[7],cFile})
        Else
            cNumMed := CND->CND_NUMMED 
			aadd(aLog,{"CONTRATO",aDeta[2][1],"OK","MEDIÇÃO "+cNumMed+" INCLUIDO COM SUCESSO",cFile})         
            oModel:DeActivate()        
           // lRet := CN121Encerr(.T.) //Realiza o encerramento da medição                   
        EndIf
    EndIf

    // Gera em tela Planilha com o log de inclussao e falhas
    GExpExcel(aLog)
Return( Nil )       


//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//  GExpExcel | Retorna Log em Excel              ||
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Static Function GExpExcel(aItem)
Local aCabExcel :={}
Local aItensExcel :=aItem

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
AADD(aCabExcel, {"REFERENCIA" ,"C", 10, 0})
AADD(aCabExcel, {"CODIGO" ,"C", 13, 0})
AADD(aCabExcel, {"STATUS" ,"C", 05, 0})
AADD(aCabExcel, {"OBS" ,"C", 50, 0})
AADD(aCabExcel, {"ARQUIVO","C",60, 0})


MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
{||DlgToExcel({{"GETDADOS",;
"LOG INCLUSAO MEDICAO VENDAS",;
aCabExcel,aItensExcel}})})

Return
