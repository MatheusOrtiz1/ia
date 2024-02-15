#Include 'Protheus.ch'

User Function CN100VST()

Local cContr := PARAMIXB[2]   
Local lOK := .T.
Local cTpCtr := CN9->CN9_TPCTO

    
   lCtrDoc := Alltrim(POSICIONE("CN1",1,xFilial("CN1")+cTpCtr,"CN1_CTRDOC")) == '1'
    
    If ! lCtrDoc  // caso o cotrole de documentos nao seja pelo padrao, obrigo a inlcuir os documentos pelo BASE DE CONHECIMENTO
        DbSelectArea("AC9")
        DbSetOrder(2)
        // Procura anexos no Contrato CN9
        If ! AC9->(DbSeek(xFilial("AC9")+'CN9'+CN9->CN9_FILIAL+cContr))
            // CASO NAO ENCONTRE ANEXOS NA CN9, BUSCA NA CND (MEDIÇÃO)
            MSGINFO( "Contrato : "+cContr+CRLF+CRLF+" ** OBRIGATORIO ANEXAR DOCUMENTO AO CONTRATO**", "DOCUMENTOS OBRIGATORIOS" )
             lOk := .F.
        ENDIF
    EndIf    

Return lOK
