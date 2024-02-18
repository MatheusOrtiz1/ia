<div id="MyWidget_${instanceId}" class="super-widget wcm-widget-class fluig-style-guide" data-params="MyWidget.instance()">
	<div class="fluig-style-guide">
		<form name="form" role="form">
			<div class="panel panel-primary main-screen" id="paramPanel" name="paramPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Par&acirc;metros</h3>
				</div>
				<div class="panel-body">
					<div class="row">
                        <div class="col-md-6 col-sm-6 col-xs-12">
							<label class="mandatory" for="filtroEmpresa">Empresa</label>
	                        <input type="text" class="form-control" id="filtroEmpresa" name="filtroEmpresa">
	                        <input type="hidden" class="form-control" id="filtroEmpresaCodigo" name="filtroEmpresaCodigo">
	                    </div>
                        <div class="col-md-6 col-sm-6 col-xs-12">
							<label class="mandatory" for="filtroFilial">Filial</label>
	                        <input type="text" class="form-control" id="filtroFilial" name="filtroFilial">
	                        <input type="hidden" class="form-control" id="filtroFilialCodigo" name="filtroFilialCodigo">
	                    </div>
					</div>
				</div>
			</div>		
			<div class="panel panel-primary main-screen" id="filterPanel" name="filterPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Filtro</h3>
				</div>
				<div class="panel-body">
					<div class="row">
                        <div class="col-md-6 col-sm-6 col-xs-12">
							<label for="filtroFornecedor">Fornecedor</label>
	                        <input type="text" class="form-control" id="filtroFornecedor" name="filtroFornecedor">
	                    </div>
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="filtroFornecedorCodigo">C&oacute;digo</label>
	                        <input type="text" class="form-control" id="filtroFornecedorCodigo" name="filtroFornecedorCodigo" readonly>
	                    </div>
                        <div class="col-md-1 col-sm-1 col-xs-12">
							<label for="filtroFornecedorLoja">Loja</label>
	                        <input type="text" class="form-control" id="filtroFornecedorLoja" name="filtroFornecedorLoja" readonly>
	                    </div>
					</div>
					<div class="row">
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="filtroDataContratoInicial">Data Contrato Inicial</label>
	                        <input type="date" class="form-control" id="filtroDataContratoInicial" name="filtroDataContratoInicial">
	                    </div>
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="filtroDataContratoFinal">Data Contrato Final</label>
	                        <input type="date" class="form-control" id="filtroDataContratoFinal" name="filtroDataContratoFinal">
	                    </div>
					</div>
					<div class="row">
                        <div class="col-md-8 col-sm-8 col-xs-12">
							<label for="filtroContrato">Contrato</label>
	                        <input type="text" class="form-control" id="filtroContrato" name="filtroContrato">
	                        <input type="hidden" class="form-control" id="filtroContratoNumero" name="filtroContratoNumero">
	                    </div>
					</div>
					<div class="row" style="margin-top: 10px;">
				        <div class="col-md-12 col-sm-12 col-xs-12">
				            <button id="btnEnviar" type="button" class="btn btn-info" data-toggle="button" onclick="enviar()">Pesquisar</button>
				        </div>
					</div>
				</div>
			</div>
			<div class="panel panel-primary main-screen" id="searchDataPanel" name="searchDataPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Contratos</h3>
				</div>
				<div class="panel-body">
					<div style="margin-top: 10px;" id="mainDataBrowse" name="mainDataBrowse">
						<table id="dataBrowse" class="dataBrowse display" style="width:100%"></table>
					</div>
				</div>
			</div>
			<div class="panel panel-primary toolbar-panel" id="contratoToolbar" name="contratoToolbar">
				<div class="row">
                    <div class="col-md-2 col-sm-2 col-xs-12">
						<button type="button" class="btn btn-primary" id="btHome" name="btHome" onclick="goHome();">Voltar</button>
					</div>
				</div>
			</div>			
			<div class="panel panel-primary contrato-ident" id="contratoIdentPanel" name="contratoIdentPanel">
	            <input type="hidden" class="form-control" id="method" name="method">
				<div class="panel-heading">
					<h3 class="panel-title">Identifica&ccedil;&atilde;o</h3>
				</div>
				<div class="panel-body">
					<div class="row">
                        <div class="col-md-6 col-sm-6 col-xs-12">
							<label class="mandatory" for="empresa">Empresa</label>
	                        <input type="text" class="form-control" id="empresa" name="empresa" readonly>
	                    </div>
                        <div class="col-md-1 col-sm-1 col-xs-12">
							<label class="mandatory" for="codigoEmpresa">C&oacute;digo</label>
	                        <input type="text" class="form-control" id="codigoEmpresa" name="codigoEmpresa" readonly>
	                    </div>
					</div>
					<div class="row">
                        <div class="col-md-6 col-sm-6 col-xs-12">
							<label class="mandatory" for="filial">Filial</label>
	                        <input type="text" class="form-control" id="filial" name="filial" readonly>
	                    </div>
                        <div class="col-md-1 col-sm-1 col-xs-12">
							<label class="mandatory" for="codigoFilial">C&oacute;digo</label>
	                        <input type="text" class="form-control" id="codigoFilial" name="codigoFilial" readonly>
	                    </div>
					</div>
					<div class="row">
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="numeroContrato">Contrato</label>
		                    <input type="text" class="form-control apply-sensitive apply-no-insert" id="numeroContrato" name="numeroContrato" onblur="getRevisao();">
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="revisao">Revis&atilde;o</label>
		                    <input type="text" class="form-control" id="revisao" name="revisao" readonly>
	                    </div>
                        <div class="col-md-7 col-sm-7 col-xs-12">
							<label for="descricaoContrato">Descri&ccedil;&atilde;o do Contrato</label>
		                    <input type="text" class="form-control" id="descricaoContrato" name="descricaoContrato" readonly>
	                    </div>
	                </div>
				</div>
			</div>
			<div class="tab-container" id="tab-container" name="tab-container">
				<div class="tabs" id="tabs" name="tabs">
				    <a href='#' id="tab-1" name="tab-1" class="tab tab-checked" onclick='tabChange(this)'>Dados do Contrato</a>
				    <a href='#' id="tab-2" name="tab-2" class="tab" onclick='tabChange(this)'>Fornecedor</a>
				    <a href='#' id="tab-3" name="tab-3" class="tab" onclick='tabChange(this)'>Medições</a>
				    <a href='#' id="tab-4" name="tab-4" class="tab" onclick='tabChange(this)'>Anexos</a>
				</div>
			</div>
			<div class="panel panel-primary contrato-dados" id="contratoDadosPanel" name="contratoDadosPanel">
				<div class="panel-body">
					<div class="row">
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="tipoRevisao">Tipo de Revis&atilde;o</label>
		                    <input type="text" class="form-control apply-sensitive apply-no-insert" id="tipoRevisao" name="tipoRevisao" readonly>
		                    <input type="hidden" class="form-control" id="codigoTipoRevisao" name="codigoTipoRevisao">
	                    </div>
                        <div class="col-md-12 col-sm-12 col-xs-12">
							<label for="justificativa">Justificativa Revis&atilde;o</label>
							<textarea class="form-control" rows="8" name="justificativa" id="justificativa" data-size="big" readonly></textarea>
	                    </div>
	                </div>
					<div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
							<label for="objeto">Objeto</label>
							<textarea class="form-control" rows="8" name="objeto" id="objeto" data-size="big" readonly></textarea>
	                    </div>
	                </div>
					<div class="row">
                        <div class="col-md-4 col-sm-3 col-xs-12">
							<label for="tipoContrato">Tipo Contrato</label>
		                    <input type="text" class="form-control" id="tipoContrato" name="tipoContrato" readonly>
		                    <input type="hidden" class="form-control" id="codigoTipoContrato" name="codigoTipoContrato">
	                    </div>
                        <div class="col-md-3 col-sm-3 col-xs-12">
							<label for="situacaoContrato">Situa&ccedil;&atilde;o</label>
		                    <input type="text" class="form-control" id="situacaoContrato" name="situacaoContrato" readonly>
		                    <input type="hidden" class="form-control" id="codigoSituacaoContrato" name="codigoSituacaoContrato">
	                    </div>
                        <div class="col-md-5 col-sm-5 col-xs-12">
							<label for="condicaoPagamento">Condi&ccedil;&atilde;o de Pagamento</label>
		                    <input type="text" class="form-control" id="condicaoPagamento" name="condicaoPagamento" readonly>
		                    <input type="hidden" class="form-control" id="codigoCondicaoPagamento" name="codigoCondicaoPagamento">
	                    </div>
	                </div>
					<div class="row">
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="dataInicio">Data de In&iacute;cio</label>
		                    <input type="date" class="form-control" id="dataInicio" name="dataInicio" readonly>
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="prazo">Prazo</label>
		                    <input type="number" class="form-control" id="prazo" name="prazo" readonly>
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="dataFinal">Data Final</label>
		                    <input type="date" class="form-control" id="dataFinal" name="dataFinal" readonly>
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="diasParaAviso">Dias Aviso</label>
		                    <input type="number" class="form-control" id="diasParaAviso" name="diasParaAviso" readonly>
	                    </div>
	                </div>
					<div class="row">
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="dataAssinatura">Data Assinatura</label>
		                    <input type="date" class="form-control" id="dataAssinatura" name="dataAssinatura" readonly>
	                    </div>
                        <div class="col-md-4 col-sm-4 col-xs-12">
							<label for="solicitante">Solicitante</label>
		                    <input type="text" class="form-control" id="solicitante" name="solicitante" readonly>
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="valorAtual">Valor Atual</label>
		                    <input type="text" class="form-control" id="valorAtual" name="valorAtual" readonly>
	                    </div>
                        <div class="col-md-2 col-sm-2 col-xs-12">
							<label for="saldo">Saldo</label>
		                    <input type="text" class="form-control" id="saldo" name="saldo" readonly>
	                    </div>
					</div>
				</div>
			</div>
			<div class="panel panel-primary contrato-fornecedor" id="contratoFornecedorPanel" name="contratoFornecedorPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Fornecedores</h3>
				</div>
				<div class="panel-body">
					<div style="margin-top: 10px;" id="fornecedorBrowse" name="fornecedorBrowse">
						<table id="fornecedorDataBrowse" class="dataBrowse display" style="width:100%"></table>
					</div>
				</div>
			</div>
			<div class="panel panel-primary contrato-medicao" id="contratoMedicaoPanel" name="contratoMedicaoPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Medi&ccedil;&otilde;es</h3>
				</div>
				<div class="panel-body">
					<div style="margin-top: 10px;" id="medicaoBrowse" name="medicaoBrowse">
						<table id="medicaoDataBrowse" class="dataBrowse display" style="width:100%"></table>
					</div>
				</div>
			</div>
			<div class="panel panel-primary contrato-anexo" id="contratoAnexoPanel" name="contratoAnexoPanel">
				<div class="panel-heading">
					<h3 class="panel-title">Anexos</h3>
				</div>
				<div class="panel-body">
                    <div style="width: 100%; text-align: right;">
						<button type="button" class="btn btn-danger" id="btDown" name="btDown" onclick="downloadAttach();" disabled>Download</button>
					</div>
					<div style="margin-top: 10px;" id="anexoBrowse" name="anexoBrowse">
						<table id="anexoDataBrowse" class="dataBrowse display" style="width:100%"></table>
					</div>
				</div>
			</div>
		</form>
	</div>
</div>
