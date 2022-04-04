<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="ISO-8859-1"%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Campeonato Paulista de Futebol de 2021</title>
	<link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
	<form action="/campeonato-paulista/grupos" method="get">
		<div align="center">
			<h3>Clique aqui para dividir os grupos</h3>
				<button type="submit" name="action" value="gerar" class="btnGerarGrupos">Dividir grupos</button>
				<button type="submit" name="action" value="mostrar" class="btnMostrarGrupos">Rodadas dos grupos</button>
		</div>
	</form>

	<br>

	<form action="/campeonato-paulista/jogos" method="get">
		<div align="center" class="divGerarJogos">
			<h3>Clique aqui para gerar os jogos</h3>
			<a href="/campeonato-paulista/jogos">
				<button type="submit" class="btnGerarJogos">Gerar jogos</button>
			</a>
		</div>
	</form>

	<br>

	<div align="center" class="">
	<h3>Pesquise os jogos por data</h3>
		<form action="/campeonato-paulista/pesquisaJogos" method="post">
			<input type="date" name="data" placeholder="Insira uma data válida"/>
			<button type="submit" class="btnPesquisarJogos">Pesquisar</button>
		</form>
	</div>
	
	<center><h4>Giullia Vital Antunes</h4></center>
</body>
</html>