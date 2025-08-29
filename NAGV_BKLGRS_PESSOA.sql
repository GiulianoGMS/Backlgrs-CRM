create or replace view nagv_bklgrs_pessoa as
-- Made by Cipolla

(
select x.seqpessoa ID_NAGUMO,
           lpad(x.nrocgccpf,9,0) || lpad(x.digcgccpf,2,0)    CPF,

/* nvl(nagf_crmfirstname(x.nomerazao),consinco.nagf_crmlastname(TRIM(x.nomerazao))  )  FIRST_NAME,
       nagf_crmmiddlename(TRIM(x.nomerazao))                                                                                 MIDDLE_NAME,
       nagf_crmlastname(TRIM(x.nomerazao))                                                                                   LAST_NAME,*/
			 x.nomerazao                                                                                                             NAME,
       REPLACE(TO_CHAR(nvl(x.Dtainclusao,x.dtahorainclusao),'YYYY-MM-DD'), ';','')            DATA_CADASTRO,
       x.sexo                  SEXO,
       REPLACE(TO_CHAR(X.DTANASCFUND,'YYYY-MM-DD'), ';','')               DATA_NASCIMENTO,
       TRIM(REPLACE(x.logradouro,CHR(9), ''))           ENDERECO,
       TRIM(REPLACE(x.Nrologradouro,CHR(9), ''))    NUMERO,
       TRIM(REPLACE(x.Cidade,CHR(9), ''))                   CIDADE,
        TRIM(REPLACE(x.Uf,CHR(9), ''))                           ESTADO,
      TRIM(REPLACE(x.CEP,CHR(9), ''))                            CEP,
			      TRIM(REPLACE(x.Cmpltologradouro,CHR(9), ''))                            COMPLEMENTO,
       TRIM(REPLACE(x.PAIS,CHR(9), ''))                          PAIS,
   case  when length(x.fonenro1)> 9  then  '+55'||x.fonenro1 when length(x.fonenro1)<= 9 then '+55'||lpad(x.foneddd1,2,0)||x.fonenro1 else null end PHONE,
   TRIM(REPLACE(x.Email,CHR(9), ''))                                                                                                                       EMAIL,

 case  when length(x.fonenro1)> 9  then  '+55'||x.fonenro1 when length(x.fonenro1)<= 9 then '+55'||lpad(x.foneddd1,2,0)||x.fonenro1 else null end                                                        TELEFONE,
      nvl(x.dtaalteracao,x.datahoraalteracao)              DATA_ALTERACAO,
      TRIM(REPLACE(Y.DEVICE_ID,CHR(9), ''))                                                                                   PUSH_DEVICE_IDS
from consinco.ge_pessoa x left join app_customer@BI y on (lpad(x.nrocgccpf,12,0)||lpad(x.digcgccpf,2,0) = lpad(y.cpf_cnpj,14,0))
WHERE nvl(x.fisicajuridica,'F') = 'F'
and x.nrocgccpf is not null
);
