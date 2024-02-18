#Include "Protheus.ch"

/*/{Protheus.doc} MT116GRV
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para manipular as informações na
importação do Conhecimento de Transporte via MATA116. Responsável também pela geração da ação do ERP
e atualização da situação do XML ao excluir o lançamento.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return Nil, Nulo
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT116GRV()
    
    //If
	//	Regra existente
	//	[...]
	//EndIf

    // Ponto de chamada ConexãoNF-e sempre como última instrução.
    U_GTPE008()
    
Return Nil
