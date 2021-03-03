# mysqldiff

Repositório para script utilizado na comparação de banco de dados [MySQL](https://www.mysql.com/).



## requisitos

Os seguintes requisitos são necessários:

- [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) versão 5.7.32 ou superior
- [mysql](https://dev.mysql.com/downloads/shell/) versão 14.14 ou superior
- [mysqldump](https://dev.mysql.com/downloads/shell/) versão 10.13 ou superior



## repositório

O projeto foi baseado na solução apresentada por [develcuy](https://stackoverflow.com/users/2108644/develcuy) em [Compare two MySQL databases](https://stackoverflow.com/questions/225772/compare-two-mysql-databases#answer-10285788).

O objeto é produzir múltiplos arquivos `.sql` com os script de criação de cada tabela presente dos bancos de dados informados.

Para então compará-los.

> &nbsp;
> **ATENÇÃO**: para uma solução completa, bem como outros bancos de dados, utilize o comando [diff](https://docs.liquibase.com/commands/community/diff.html) do [Liquibase](https://docs.liquibase.com/home.html),
> &nbsp;



# comandos

Para execução do script utilize o seguinte comando:

```bash
mysqldiff.sh --left-hostname <LEFT_HOSTNAME> --left-user <LEFT_USERNAME> --left-password <LEFT_PASSWORD> --left-database <LEFT_DATABASE> --right-hostname <RIGHT_HOSTNAME> --right-user <RIGHT_USERNAME> --right-password <RIGHT_PASSWORD> --right-database <RIGHT_DATABASE>
```

Ou execute outra variação do mesmo comando na qual os parâmetros são obtidos via váriais de ambiente:

```bash
mysqldiff.sh
```

As variáveis de ambiente poderão ser definidas por meio de um arquivo `.env`.
