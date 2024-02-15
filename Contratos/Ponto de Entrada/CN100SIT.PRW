#include "totvs.ch"

/*
Programa.: CN100SIT.PRW
Tipo.....: Ponto de Entrada
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 01/08/2023
Descrição: Ponto de entrada na alteração da situação do contrato
Notas....: É executado após a alteração da situação do contrato, quando é definido que o contrato passará de uma 
           situação para outra. Sua execução ocorre após o processamento interno do sistema.
*/

#define DEF_CANC '01' //Cancelado
#define DEF_ELAB '02' //Em Elaboração
#define DEF_EMIT '03' //Emitido
#define DEF_APRO '04' //Em Aprovação
#define DEF_VIGE '05' //Vigente
#define DEF_PARA '06' //Paralisado
#define DEF_SFIN '07' //Sol Fina.
#define DEF_FINA '08' //Finalizado
#define DEF_REVS '09' //Revisão  
#define DEF_REVD '10' //Revisado

/*/{Protheus.doc} cstContratoFluig 
Função de chamada do ponto de entrada
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 01/08/2023
@version 1.0
@type function
/*/
user function CN100SIT()
    local areaDEF   := getArea()
    local areaCN9   := CN9->(getArea())
    local areaCNC   := CNC->(getArea())
    local cCurrent  := paramIXB[1]
    local cNew      := paramIXB[2]
    local oContrato := nil
    local cSolicita := "Indefinido"
    local wasFound  := .f.
    
    private oUser   := nil
    private oAlerts := nil

	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    oUser := pfwUser():New()
    oUser:Find(retCodUsr())
    if !oUser:Available 
        cSolicita := oUser:GetName()
    endIf
    oUser:Destroy()

    if !CN9->(eof()) ;
        .and. (cCurrent != cNew) 

        dbSelectArea("CNC")
        CNC->(dbSetOrder(1))    //CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA
        CNC->(dbSeek(xFilial("CNC") + CN9->CN9_NUMERO + CN9->CN9_REVISA))

        if !CNC->(eof()) ;
            .and. (cNew == DEF_VIGE .or. cNew == DEF_REVD) ;
            
            oContrato := contratosFluig():New()
            wasFound  := oContrato:Find(CN9->CN9_NUMERO, "PROTHEUS", CN9->CN9_REVISA)

            if wasFound            
                oContrato:BeginRecord("update")
            else 
                oContrato:BeginRecord("insert")
                oContrato:SetValue("ZAL_FILIAL", CN9->CN9_FILIAL)
                oContrato:SetValue("ZAL_NUMERO", CN9->CN9_NUMERO)
                oContrato:SetValue("ZAL_ORIGEM", "PROTHEUS")
                oContrato:SetValue("ZAL_REVISA", CN9->CN9_REVISA)
                oContrato:SetValue("ZAL_TIPREV", CN9->CN9_TIPREV)
                oContrato:SetValue("ZAL_JUSTIF", CN9->CN9_JUSTIF)
            endIf 

            oContrato:SetValue("ZAL_CC"    , "")
            oContrato:SetValue("ZAL_SITUAC", CN9->CN9_SITUAC)
            oContrato:SetValue("ZAL_SOLICI", cSolicita)
            oContrato:SetValue("ZAL_FORNEC", CNC->CNC_CODIGO)
            oContrato:SetValue("ZAL_LOJA"  , CNC->CNC_LOJA)
            oContrato:SetValue("ZAL_TIPCTR", CN9->CN9_TPCTO)
            oContrato:SetValue("ZAL_OBJETO", CN9->CN9_OBJCTO)
            oContrato:SetValue("ZAL_RESPJU", "")
            oContrato:SetValue("ZAL_DTINIC", CN9->CN9_DTINIC)
            oContrato:SetValue("ZAL_PRAZO" , (CN9->CN9_DTFIM - CN9->CN9_DTINIC))
            oContrato:SetValue("ZAL_DTFINA", CN9->CN9_DTFIM)
            oContrato:SetValue("ZAL_DTASSI", CN9->CN9_DTASSI)
            oContrato:SetValue("ZAL_AVISO" , 10)
            oContrato:SetValue("ZAL_VALOR" , CN9->CN9_VLATU)
            oContrato:SetValue("ZAL_SALDO" , CN9->CN9_SALDO)
            oContrato:EndRecord()

            if wasFound
                oContrato:Update()
            else
                oContrato:Insert()
            endIf 

            oAlerts:AddFrom(oContrato)
            oContrato:Destroy()
        endIf 
    endIf

    oAlerts:Show()
    oAlerts:Destroy()

    restArea(areaCNC)
    restArea(areaCN9)
    restArea(areaDEF)
return
