
//-------------------------------------------------------------------------
//Programa: MT110APV        Autor: Everton Forti        Data:22/07/2022   |
//-------------------------------------------------------------------------
//Ponto de entrada para validar Aprovação de Solicitação de Compra        |
//Permiti aprovar somente usuários que estão cadastrados como Aprovadores |
//-------------------------------------------------------------------------
User Function MT110APV()
//Local cParam1:=ParamIxb[1]
//Local nParam2:=ParamIxb[2]
Local lRet:=.F.// Validações //
lOCAL cUserId   := RetCodUsr()
Local lAtiva := SUPERGETMV("MV_UAPVSOL",.F.,.F.) //ATIVA CONTROLE ALÇADAS

    IF lAtiva
        dbSelectArea('SAK')//APROVADORES
        dbSetOrder(2)
        IF dbSeek(xFilial('SAK')+cUserId)
            lRet:=.T.
        ELSE
            MSGINFO("Usuário sem acesso ao controle de Alçadas para libear solicitação!","MT110APV")
        ENDIF
    ELSE
        lRet:=.T.
    ENDIF

Return lRet
