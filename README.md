# anonymization-script
Skrypt służy do pobrania ostatniego backupu bazy danych z serwera, zanonimizowania jej oraz wysłania na inny serwer.

# Wymagania 
1. Zainstalowane programy:
	* 7z;
	* WinSCP;
	* SQL Server (z opcją uwierzytelniania: _Windows Authentication_);
2. W folderze ze skryptem program *mailsend1.19.exe*. Link do strony: *https://www.npackd.org/p/mailsend/1.19*;

# Przed użyciem
Przed pierwszym użyciem należy:
1. uzupełnić dane do konfiguracji:
	* mailFrom: nazwa nagłówka;
	* mailAddress: adres maila, z którego będzie wysłana wiadomość;
	* mailPass: hasło do skrzynki pocztowej;
	* mailSMTP: Hostname/IP SMTP serwera;
	* mailRecipients: adresy odbiorców;
	* mailSubject: tytuł maila;
	* PATH: ścieżka do plików _7z_ oraz _WinSCP_;
	* localPath: ścieżka gdzie lokalnie ma być pobrana baza danych;
	* ftpPath: ścieżka gdzie na serwerze znajduje się backup bazy danych, z którego ma być pobierana;
	* destinationPath: ścieżka gdzie na serwerze ma znaleźć się zanonimizowana baza danych;
	* dbData: nazwa serwera lokalnej bazy danych; 
	* nameAnonymizatedDb: nazwę zanonimizowanej bazy danych (domyślnie: _db_prod_ano_);
	* nameBackupDb: nazwa backupu bez rozszerzenia .bak (domyślnie: _db_prod_full_);
	* nameDb: nazwa bazy danych (domyślnie: _db_prod_);
	* logDb: nazwa logów bazy danych (domyślnie: _db_prod_log_);
2. w pliku *wscp_script_get_start* uzupełnić dane uwierzytelniania dla serwera, z którego ostatni backup bazy danych ma zostać pobrany;
3. w pliku *wscp_script_put_start* uzupełnić dane uwierzytelniania dla serwera, do którego ma zostać wysłana zanonimizowana baza danych;
4. Jeżeli zmienne związane z bazą danych zostały zmienione należy również edytować plik: *shrinkdb.sql* oraz *anonymization.sql*.
