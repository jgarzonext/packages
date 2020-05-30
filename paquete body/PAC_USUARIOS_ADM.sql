--------------------------------------------------------
--  DDL for Package Body PAC_USUARIOS_ADM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_USUARIOS_ADM" 
IS
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- VARIABLES PRIVADAS
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   -- AUDITORIA ULTIMO ERROR
   VREG_AUDITAR   TREG_AUDITAR   ;  -- VARIABLE registro Auditoria de ULTIMO ERROR REGISTRADO
   VS_FUNCTION    VARCHAR2(30)   ;  -- Ultima FUNCION llamada   ... f?_*() para registrar error
   VS_ACCION      VARCHAR2(6)    ;  -- Ultima ACCION realizada ... CREATE;ALTER;DROP;...
   -- PARINSTALACION
   VS_OWNER       VARCHAR2(30)   := f_parinstalacion_t('OWN_SCHEMA');   -- Propietario de los objetos (para sinonimos)
   VS_GRANT       VARCHAR2(30)   := f_parinstalacion_t('USTF_GRANT');   -- Permisos acceso usuarios del TERMINAL
   VS_TBS_DEF     VARCHAR2(30)   := f_parinstalacion_t('USTF_TSDEF');   -- Tablespace por defecto del usuario a crear
   VS_TBS_TMP     VARCHAR2(30)   := f_parinstalacion_t('USTF_TSTMP');   -- Tablespace temporal del usuario a crear
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- DEFINICIONES PRIVADAS DE LITERALES (para mejor lectura codigo fuente)
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   NL_TFDB_OK0          LITERALES.SLITERA%TYPE  DEFAULT  000000;  -- No hay error (en realidad es el literal NL_TFDB_OK_LIT)
   NL_TFDB_OK_LIT       LITERALES.SLITERA%TYPE  DEFAULT  151605;  -- No hay error (equivale a la devolucion de NL_TFDB_OK0)
   NL_TFDB_DBACCESS     LITERALES.SLITERA%TYPE  DEFAULT  151606;  -- No se puede conectar a la DBMS
   NL_TFDB_NOPARINST    LITERALES.SLITERA%TYPE  DEFAULT  151607;  -- No existe definicion en parinstalacion
   NL_TFDB_USTF_SCHEM   LITERALES.SLITERA%TYPE  DEFAULT  151608;  -- No existe definicion en parinstalacion
   NL_TFDB_USTF_GRANT   LITERALES.SLITERA%TYPE  DEFAULT  151609;  -- No existe definicion en parinstalacion
   NL_TFDB_USTF_TSDEF   LITERALES.SLITERA%TYPE  DEFAULT  151610;  -- No existe definicion en parinstalacion
   NL_TFDB_USTF_TSTMP   LITERALES.SLITERA%TYPE  DEFAULT  151611;  -- Este usuario no se puede borrar
   NL_TFDB_NOCREAUSU    LITERALES.SLITERA%TYPE  DEFAULT  151612;  -- Este usuario no se puede crear
   NL_TFDB_NOALTERUSU   LITERALES.SLITERA%TYPE  DEFAULT  151613;  -- Este usuario no se puede alterar
   NL_TFDB_NODROPUSU    LITERALES.SLITERA%TYPE  DEFAULT  151614;  -- Este usuario no se puede alterar
   NL_TFDB_DINSQL       LITERALES.SLITERA%TYPE  DEFAULT  151615;  -- Error en SQL dinamico
   NL_TFDB_NODROPUSUEX  LITERALES.SLITERA%TYPE  DEFAULT  151616;  -- El usuario a borrar NO EXISTE
   NL_TFDB_NOCDELEGAEX  LITERALES.SLITERA%TYPE  DEFAULT  151617;  -- La delegacion solicitada NO EXISTE
   NL_TFDB_RESERVADO_03 LITERALES.SLITERA%TYPE  DEFAULT  151618;  --
   NL_TFDB_RESERVADO_04 LITERALES.SLITERA%TYPE  DEFAULT  151619;  --
   NL_TFDB_RESERVADO_05 LITERALES.SLITERA%TYPE  DEFAULT  151620;  --
   NL_TFDB_RESERVADO_06 LITERALES.SLITERA%TYPE  DEFAULT  151621;  --
   NL_TFDB_RESERVADO_07 LITERALES.SLITERA%TYPE  DEFAULT  151622;  --
   NL_TFDB_RESERVADO_08 LITERALES.SLITERA%TYPE  DEFAULT  151623;  --
   NL_TFDB_RESERVADO_09 LITERALES.SLITERA%TYPE  DEFAULT  151624;  --
   NL_TFDB_RESERVADO_10 LITERALES.SLITERA%TYPE  DEFAULT  151625;  --
   NL_TFDBXX            LITERALES.SLITERA%TYPE  DEFAULT  151626;  -- Error GENERICO no registrado
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- CABECERAS PRIVADAS
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
FUNCTION
   f_execute
   ( ps_sql IN VARCHAR2, pb_want_trc IN BOOLEAN DEFAULT TRUE )
   RETURN  NUMBER;
FUNCTION
   f_tabla_usuarios
   ( ps_username IN VARCHAR2, ps_full_name IN VARCHAR2, pn_cidioma IN VARCHAR2, pn_cdelega IN NUMBER )
   RETURN  NUMBER;
PROCEDURE
   p_set_accion
   ( ps_username IN VARCHAR2, ps_accion IN VARCHAR2 );
PROCEDURE
   p_info_module
   ( ps_action IN VARCHAR2, pn_total IN NUMBER );
PROCEDURE
   p_info_action
   ( ps_action IN VARCHAR2, pn_current IN NUMBER );
  -----------------------------------------------------------------------------
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- Cuerpos Privados
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
FUNCTION
   f_execute
   ( ps_sql IN VARCHAR2, pb_want_trc IN BOOLEAN DEFAULT TRUE )
   RETURN  NUMBER
IS
BEGIN
   -- 1. Ejecutamos la instruccion
   EXECUTE IMMEDIATE ps_sql ;

   RETURN  NL_TFDB_OK0;
EXCEPTION
WHEN OTHERS THEN
   p_set_error(
      pn_error    => NL_TFDB_DINSQL,
      pn_sqlcode  => SQLCODE,
      ps_sqlerrm  => SQLERRM,
      ps_function => 'f_execute '||ps_sql
      );
   RETURN  SQLCODE;
END     f_execute;
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
FUNCTION
   f_tabla_usuarios
   ( ps_username IN VARCHAR2, ps_full_name IN VARCHAR2, pn_cidioma IN VARCHAR2, pn_cdelega IN NUMBER )
   RETURN  NUMBER
IS
   vb_existe_usu   BOOLEAN;
   vreg_usu_table  usuarios%ROWTYPE;
BEGIN
   -- Dime si existe usuario en tabla de usuarios
   BEGIN
      SELECT *
      INTO   vreg_usu_table
      FROM   usuarios
      WHERE  cusuari = UPPER( ps_username )
         ;
      vb_existe_usu   := TRUE;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      vb_existe_usu   := FALSE;
   END;
   -- ¿Insertar o Updatear USUARIOS? Igualmente pon el usuario a FBAJA=NULL
   IF vb_existe_usu THEN
      UPDATE
            usuarios
      SET   cidioma  = pn_cidioma   ,
            cdelega  = pn_cdelega   ,
            fbaja    = NULL
      WHERE cusuari  = UPPER(ps_username)
            ;
   ELSE
      INSERT INTO
         usuarios
         (
         cusuari,
         cidioma,
         cempres,
         tpcpath,
         tusunom,
         cdelega,
         copcion
         )
      VALUES  (
         UPPER(ps_username),  -- cusuari
         pn_cidioma ,         -- cidioma
         1          ,         -- cempres
         'C:\'      ,         -- tpcpath
         ps_full_name,        -- tusunom
         pn_cdelega,          -- cdelega
         0                    -- opción de menú
         );
   END IF;
   COMMIT;

   RETURN  NL_TFDB_OK0;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END     f_tabla_usuarios;
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PROCEDURE
   p_set_accion
   ( ps_username IN VARCHAR2, ps_accion IN VARCHAR2 )
IS
BEGIN
   VREG_AUDITAR.cusuari    := ps_username;
   VREG_AUDITAR.taccion    := ps_accion;
   VREG_AUDITAR.tfuncion   := ps_accion;
   VREG_AUDITAR.faccion    := SYSDATE;
-- VREG_AUDITAR.err_lcode  := 0;
-- VREG_AUDITAR.err_lerrm  := NULL;
-- VREG_AUDITAR.err_sqlcode:= 0;
-- VREG_AUDITAR.err_sqlerrm:= NULL;
END   p_set_accion;
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PROCEDURE
   p_info_module
   ( ps_action IN VARCHAR2, pn_total IN NUMBER )
IS
   vs_out  VARCHAR2(100);
BEGIN
   vs_out  := ps_action||'('||pn_total||')';
   vs_out  := vs_out||TO_CHAR(SYSDATE,'HH24:MI:SS');
   DBMS_APPLICATION_INFO.SET_MODULE( vs_out, NULL );
END     p_info_module;
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PROCEDURE
   p_info_action
   ( ps_action IN VARCHAR2, pn_current IN NUMBER )
IS
   vs_out  VARCHAR2(100);
BEGIN
   vs_out  := ps_action||'('||pn_current||')';
   vs_out  := vs_out||TO_CHAR(SYSDATE,'HH24:MI:SS');
   DBMS_APPLICATION_INFO.SET_ACTION( vs_out );
END     p_info_action;
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -----------------------------------------------------------------------------
  -- Cuerpos Publicos
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
FUNCTION
   f_create_user
   ( ps_username IN VARCHAR2, ps_full_name IN VARCHAR2, pn_cidioma IN VARCHAR2, pn_cdelega IN NUMBER, pn_error OUT CODLITERALES.SLITERA%TYPE )
   RETURN  NUMBER
IS
   vs_sql_var           VARCHAR2(4000);
   vs_sql_fixed         VARCHAR2(4000);
   vs_sql               VARCHAR2(4000);
   vn_return            NUMBER      := NL_TFDB_OK0;
   vn_err               NUMBER      ;
   vn_existe            NUMBER      ;
   vs_tbsdefault        VARCHAR2(30);
   vs_tbstemp           VARCHAR2(30);
   EXCP_TF_RECONOCIDA   EXCEPTION   ;
   vs_password          VARCHAR2(30);
BEGIN
   pn_error    := NL_TFDB_OK0;
   p_info_module( ps_username, 0 );
   VS_FUNCTION := 'f_create_user';
   ------------------------------------
   -- 0. CONTROL PARINSTALACION
   ------------------------------------
   IF f_clear_error != NL_TFDB_OK0 THEN
      RAISE EXCP_TF_RECONOCIDA;
   END IF;
   ------------------------------------
   -- 1. Investigar si CDELEGA no existe
   ------------------------------------
   BEGIN
      SELECT
            cagente
      INTO  vn_existe
      FROM  agentes
      WHERE cagente  = pn_cdelega
            ;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_set_error(
         pn_error    => NL_TFDB_NOCDELEGAEX,
         pn_sqlcode  => SQLCODE,
         ps_sqlerrm  => 'La delegacion no existe',
         ps_function => 'f_create_user '||VS_ACCION
         );
      RAISE EXCP_TF_RECONOCIDA;
   END;
   ------------------------------------
   -- 1. INSTRUCCION CREATE USER
   ------------------------------------
   -- Password
   vs_password     := f_parinstalacion_t('PASSWORD');
   -- Default tablespaces
   vs_tbsdefault   := NVL(f_parinstalacion_t('USTF_TSDEF'),'users');
   vs_tbstemp      := NVL(f_parinstalacion_t('USTF_TSTMP'),'temp');
   -- Resto de la cadena
   vs_sql_fixed    := '';
   vs_sql_fixed    := vs_sql_fixed||' IDENTIFIED BY "'||vs_password||'"'||CHR(10);
   vs_sql_fixed    := vs_sql_fixed||' DEFAULT   TABLESPACE '||vs_tbsdefault||CHR(10);
   vs_sql_fixed    := vs_sql_fixed||' TEMPORARY TABLESPACE '||vs_tbstemp   ||CHR(10);
   vs_sql_fixed    := vs_sql_fixed||' QUOTA 0M ON SYSTEM';


   VS_ACCION   := 'CREATE';
   vs_sql_var  := 'CREATE USER '||ps_username||CHR(10);
   vs_sql      := vs_sql_var||vs_sql_fixed;

   vn_return   := f_execute( vs_sql );
   IF vn_return != NL_TFDB_OK0 THEN
      p_set_error(
         pn_error    => NL_TFDB_NOCREAUSU,
         pn_sqlcode  => VREG_AUDITAR.err_sqlcode,
         ps_sqlerrm  => VREG_AUDITAR.err_sqlerrm,
         ps_function => 'f_create_user '||VS_ACCION
         );
      RAISE EXCP_TF_RECONOCIDA;
   END IF;
   ------------------------------------
   -- 2. Permisos, roles, conexion
   ------------------------------------
   vs_sql      := 'GRANT '||VS_GRANT||' TO '||ps_username;
   vn_return   := f_execute( vs_sql );
   -- Permisos sobre esquema
 --  IF vn_existe = NL_TFDB_OK0 THEN
      vn_return:= f_create_see_syns( ps_username, VS_OWNER );
--   END IF;
   ------------------------------------
   -- 3. Actuar sobre la tabla USUARIOS
   ------------------------------------
   vn_return   := f_tabla_usuarios(
      ps_username    => ps_username  ,
      ps_full_name   => ps_full_name ,
      pn_cidioma     => pn_cidioma   ,
      pn_cdelega     => pn_cdelega
      );
   RETURN  vn_return;
EXCEPTION
WHEN EXCP_TF_RECONOCIDA THEN
   pn_error := f_get_error;
   RETURN   1;
WHEN OTHERS THEN
   RETURN   SQLCODE;
END     f_create_user;
  -----------------------------------------------------------------------------
FUNCTION
   f_drop_user
   ( ps_username IN VARCHAR2, pn_error OUT CODLITERALES.SLITERA%TYPE )
   RETURN  NUMBER
IS
   vs_sql               VARCHAR2(4000);
   vn_return            NUMBER      := NL_TFDB_OK0;
   vs_existe            ALL_USERS.USERNAME%TYPE;
   EXCP_TF_RECONOCIDA   EXCEPTION   ;
BEGIN
   pn_error    := NL_TFDB_OK0;
   VS_FUNCTION := 'f_drop_user';
   ------------------------------------
   -- 0. CONTROL PARINSTALACION
   ------------------------------------
   IF f_clear_error != NL_TFDB_OK0 THEN
      RAISE EXCP_TF_RECONOCIDA;
   END IF;
   ------------------------------------
   -- 1. EVITAR BORRAR USUARIOS ESPECIALES
   ------------------------------------
   IF ps_username NOT IN('SYS','SYSTEM','AXIS') THEN
      -- 1.1.a. NO Borramos de USUARIOS, damos de baja
      UPDATE
            usuarios
      SET   fbaja   = SYSDATE
      WHERE cusuari = UPPER( ps_username )
            ;
      -- 1.1.b. Ver si el usuario existe en USERS
      BEGIN
         SELECT
               username
         INTO  vs_existe
         FROM  all_users
         WHERE username = UPPER(ps_username)
               ;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_set_error( NL_TFDB_NODROPUSUEX, SQLCODE, SQLERRM, 'f_drop_user' );
         RAISE EXCP_TF_RECONOCIDA;
      END;
      -- 1.1.c. Eliminamos de DBMS
      VS_ACCION   := 'DROP';
      vs_sql      := '';
      vs_sql      := vs_sql||'DROP USER '||ps_username||' CASCADE';
      vn_return   := f_execute( vs_sql );
   ELSE
      -- 1.2 Este tipo de usuario no se debe eliminar !!!!!
      p_set_error( NL_TFDB_NODROPUSU, SQLCODE, SQLERRM, 'f_drop_user' );
      RAISE EXCP_TF_RECONOCIDA;
   END IF;
   RETURN   vn_return;
EXCEPTION
WHEN EXCP_TF_RECONOCIDA THEN
   pn_error := f_get_error;
   RETURN   pn_error;
WHEN OTHERS THEN
   p_set_error( NL_TFDBXX, SQLCODE, SQLERRM, 'f_drop_user' );
   RETURN   f_get_error;
END     f_drop_user;
  -----------------------------------------------------------------------------
FUNCTION
   f_grant_tf
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER
IS
   vs_sql     VARCHAR2( 480 );
   vs_priv    VARCHAR2( 30 );
   vn_return  NUMBER        := NL_TFDB_OK0;
   vn_total   NUMBER        ;
   CURSOR  cc      IS
      SELECT object_type     ,
             object_name
      FROM   all_objects
      WHERE  owner = UPPER(ps_owner)
      AND    object_type     IN
             (
             'TABLE'    ,
             'VIEW'     ,
             'SEQUENCE'      ,
             'PROCEDURE'     ,
             'FUNCTION'      ,
             'PACKAGE'
             )
      ORDER BY
             object_type     ,
             object_name
             ;
BEGIN
   VS_FUNCTION := 'f_grant_tf';
   -- Averiguar cuantos objetos para monitorizar en V$SESSION
   SELECT COUNT(1)
   INTO   vn_total
   FROM   all_objects
   WHERE  owner = UPPER(ps_owner)
   AND    object_type     IN
          (
          'TABLE'       ,
          'VIEW'        ,
          'SEQUENCE'    ,
          'PROCEDURE'   ,
          'FUNCTION'    ,
          'PACKAGE'
          );
   p_info_module( 'GRANT', vn_total );
   -- Aplicacion de permisos caso por caso
   FOR reg IN cc LOOP
      BEGIN
      -- Escoger los privilegios
      IF    reg.object_type IN ('TABLE','VIEW') THEN
         vs_priv := 'SELECT,INSERT,UPDATE,DELETE';
      ELSIF reg.object_type IN ('SEQUENCE') THEN
         vs_priv := 'SELECT';
      ELSIF reg.object_type IN ('PROCEDURE','FUNCTION','PACKAGE') THEN
         vs_priv := 'EXECUTE';
      END IF;
      -- Aplicarlos
      vs_sql    := '';
      vs_sql    := vs_sql||'GRANT '||vs_priv;
      vs_sql    := vs_sql||' ON '||ps_owner||'.'||reg.object_name;
      vs_sql    := vs_sql||' TO '||ps_username;
      vn_return := f_execute( vs_sql );
      p_info_action( '', cc%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
         vn_return := SQLCODE;
      END;
   END LOOP;
   RETURN  vn_return;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END     f_grant_tf;
  -----------------------------------------------------------------------------
FUNCTION
   f_create_see_syns
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER
IS
   vn_return   NUMBER  := NL_TFDB_OK0;
   vs_sql      VARCHAR2( 480 );
   vn_syns     NUMBER;
   vn_objs     NUMBER;
   vn_err_syns NUMBER;
BEGIN
   VS_FUNCTION := 'f_create_see_syns';
   -- Averiguar cuantos casos de publicos y cuantos objetos a referenciar
   SELECT  COUNT(*)
   INTO    vn_syns
   FROM    all_synonyms    s
   WHERE   s.owner    = 'PUBLIC'
   AND     s.table_owner   = UPPER(ps_owner)
           ;
   SELECT  COUNT(*)
   INTO    vn_objs
   FROM    all_objects     o
   WHERE   o.owner    = UPPER(ps_owner)
   AND     o.object_type   IN
           (
           'TABLE'    ,
           'VIEW'     ,
           'SEQUENCE'      ,
           'PROCEDURE'     ,
           'FUNCTION'      ,
           'PACKAGE'
           );
   -- ¿Existen sinonimos publicos?
   IF (vn_syns / vn_objs) <= 0.5 THEN
      vn_return       := f_create_private_syns( ps_username, VS_OWNER );
   ELSE
      -- ¿Si hay tantos sinonimos publicos para el esquema propietario, sobra el crear privados?
      -- Independientemente si publicos o privados, crear los especiales (PAISES,MENSAJE,VENTAS)
      vn_return       := f_create_private_syns_special( ps_username, VS_OWNER );
   END IF;

   RETURN  vn_return;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END     f_create_see_syns;
  -----------------------------------------------------------------------------
FUNCTION
   f_create_private_syns
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER
IS
   vn_return  NUMBER  := NL_TFDB_OK0;
   vs_sql     VARCHAR2( 480 );
   vn_total   NUMBER;
   CURSOR  cc      IS
      -- Privados dif nombre a nombre tabla todavia no existentes
      SELECT  synonym_name    ,
              table_name
      FROM    all_synonyms
      WHERE   owner      = UPPER(ps_owner)
      AND     table_owner= UPPER(ps_owner)
         UNION
      SELECT  object_name     synonym_name,
              object_name     table_name
      FROM    all_objects
      WHERE   owner       = UPPER(ps_owner)
      AND     object_type IN
              (
              'TABLE'    ,
              'VIEW'     ,
              'SEQUENCE'      ,
              'PROCEDURE'     ,
              'FUNCTION'      ,
              'PACKAGE'
              )
      ORDER BY
              synonym_name    ,
              table_name
              ;
BEGIN
   VS_FUNCTION := 'f_create_private_syns';
   -- Privados iguales
   SELECT  COUNT(1)
   INTO    vn_total
   FROM    (
           SELECT  synonym_name    ,
                   table_name
           FROM    all_synonyms
           WHERE   owner      = UPPER(ps_owner)
           AND     table_owner= UPPER(ps_owner)
                   UNION
           SELECT  object_name     synonym_name    ,
                   object_name     table_name
           FROM    all_objects
           WHERE   owner      = UPPER(ps_owner)
           AND     object_type     IN
                   (
                   'TABLE'    ,
                   'VIEW'     ,
                   'SEQUENCE' ,
                   'PROCEDURE',
                   'FUNCTION' ,
                   'PACKAGE'
           )       );
   p_info_module( 'SYN', vn_total );
   FOR reg IN cc LOOP
      BEGIN
      vs_sql   := 'CREATE SYNONYM '||ps_username||'.'||reg.synonym_name;
      vs_sql   := vs_sql||' FOR '||ps_owner||'.'||reg.table_name;
      vn_return:= f_execute( vs_sql );
      p_info_action( '', cc%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
         /* ORA-00955 name is already used by an existing object */
         IF SQLCODE!=-955 THEN
            RETURN  SQLCODE;
         END IF;
      END;
   END LOOP;
   RETURN  vn_return;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END     f_create_private_syns;
  -----------------------------------------------------------------------------
FUNCTION
   f_create_private_syns_special
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER
IS
   vn_return  NUMBER  := NL_TFDB_OK0;
   vs_sql     VARCHAR2( 480 );
   vn_total   NUMBER;
   vs_table		VARCHAR2(30);
   CURSOR  cc      IS
      -- Privados dif nombre a nombre tabla todavia no existentes
      SELECT  object_name     synonym_name,
              object_name     table_name
      FROM    all_objects
      WHERE   owner       = UPPER(ps_owner)
      AND     object_name IN
              (
              'MENSAJE'    ,
              'PAISES'     ,
              'VENTAS'
              )
      ORDER BY
              object_name
              ;
BEGIN
   VS_FUNCTION := 'f_create_private_syns_special';
   -- Privados iguales
   FOR reg IN cc LOOP
      BEGIN
			IF reg.synonym_name = 'MENSAJE' THEN
				-- El sinonimo privado es especial
				vs_table := 'IFASES_A_HOST';
			ELSE
				-- El sinonimo privado coincide con el nombre la tabla
				vs_table	:= reg.table_name;
			END IF;
	      -- Sentencia SQL
	      vs_sql   := 'CREATE SYNONYM '||ps_username||'.'||reg.synonym_name;
	      vs_sql   := vs_sql||' FOR '||ps_owner||'.'||vs_table;
	      vn_return:= f_execute( vs_sql );
      EXCEPTION
      WHEN OTHERS THEN
         /* ORA-00955 name is already used by an existing object */
         IF SQLCODE!=-955 THEN
            RETURN  SQLCODE;
         END IF;
      END;
   END LOOP;
   RETURN  vn_return;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END f_create_private_syns_special;
  -----------------------------------------------------------------------------
FUNCTION
   f_tiene_objetos
   ( ps_username IN VARCHAR2 )
   RETURN BOOLEAN
IS
   vn_objetos      NUMBER;
   vb_objetos      BOOLEAN;
-- Valores de variable objetos
-- Si tiene no objetos = 0
-- Si tiene si objetos = 1
BEGIN
   -- Averiguar si esquema tiene objetos
   SELECT COUNT(*)
   INTO   vn_objetos
   FROM   all_objects
   WHERE  owner    =  UPPER(ps_username)
          ;
   -- Indicar cual va a ser el retorno
   IF vn_objetos > 0 THEN
      vb_objetos      := TRUE;
   ELSE
      vb_objetos      := FALSE;
   END IF;
   RETURN  vb_objetos;
END     f_tiene_objetos;
  -----------------------------------------------------------------------------
FUNCTION
   f_drop_objects
   ( ps_username IN VARCHAR2 )
   RETURN  NUMBER
IS
   vs_sql     VARCHAR2(480);
   vn_return  NUMBER  := NL_TFDB_OK0;
   CURSOR  cc IS
      SELECT  object_type     ,
              object_name
      FROM    all_objects
      WHERE   owner      = UPPER(ps_username)
      AND     object_type     != 'PACKAGE BODY'
      ORDER BY
              object_type     ,
              object_name
              ;
BEGIN
   VS_FUNCTION := 'f_drop_objects';
   -- Borrar caso por caso
   FOR reg IN cc LOOP
      vs_sql    := 'DROP '||reg.object_type||' '||ps_username||'.'||reg.object_name;
      vn_return := f_execute( vs_sql );
   END LOOP;
EXCEPTION
WHEN OTHERS THEN
   RETURN  SQLCODE;
END     f_drop_objects;
  -----------------------------------------------------------------------------
  -- ERRORES
  -----------------------------------------------------------------------------
FUNCTION
   f_clear_error
   RETURN   CODLITERALES.SLITERA%TYPE
IS
   VN_NODATAFOUND NUMBER   DEFAULT -01403;
   vn_error       CODLITERALES.SLITERA%TYPE  := NL_TFDB_OK0 ;
BEGIN
   -- (1) Recogemos sobre variables las entradas PARINSTALACION necesarias
   VS_OWNER       := f_parinstalacion_t('OWN_SCHEMA');
   VS_GRANT       := f_parinstalacion_t('USTF_GRANT');
   VS_TBS_DEF     := f_parinstalacion_t('USTF_TSDEF');
   VS_TBS_TMP     := f_parinstalacion_t('USTF_TSTMP');
   -- (2) Verificacion existencia de los parametros en parinstalacion
   IF    VS_OWNER    IS NULL  THEN
      vn_error := NL_TFDB_USTF_SCHEM ;
      p_set_error( NL_TFDB_USTF_SCHEM, VN_NODATAFOUND, 'NO_DATA_FOUND PARINSTALACION ''OWN_SCHEMA''', 'f_clear_error' );
   ELSIF VS_GRANT    IS NULL  THEN
      vn_error := NL_TFDB_USTF_GRANT ;
      p_set_error( NL_TFDB_USTF_GRANT, VN_NODATAFOUND, 'NO_DATA_FOUND PARINSTALACION ''USTF_GRANT''', 'f_clear_error' );
   ELSIF VS_TBS_DEF  IS NULL  THEN
      vn_error := NL_TFDB_USTF_TSDEF ;
      p_set_error( NL_TFDB_USTF_TSDEF, VN_NODATAFOUND, 'NO_DATA_FOUND PARINSTALACION ''USTF_TSDEF''', 'f_clear_error' );
   ELSIF VS_TBS_TMP  IS NULL  THEN
      vn_error := NL_TFDB_USTF_TSTMP ;
      p_set_error( NL_TFDB_USTF_TSTMP, VN_NODATAFOUND, 'NO_DATA_FOUND PARINSTALACION ''USTF_TSTMP''', 'f_clear_error' );
   ELSE
      -- No hay errores
      VREG_AUDITAR.cusuari    := F_USER;
      VREG_AUDITAR.taccion    := VS_ACCION;
      VREG_AUDITAR.tfuncion   := NULL;
      VREG_AUDITAR.faccion    := NULL;
      VREG_AUDITAR.err_lcode  := 0;
      VREG_AUDITAR.err_lerrm  := NULL;
      VREG_AUDITAR.err_sqlcode:= 0;
      VREG_AUDITAR.err_sqlerrm:= NULL;
   END IF;
   -- (3) RETORNO DE LA FUNCION
   RETURN   NVL(vn_error,NL_TFDB_OK0);
EXCEPTION
WHEN OTHERS THEN
   RETURN   NVL(vn_error,NL_TFDB_OK0);
END   f_clear_error;
  -----------------------------------------------------------------------------
PROCEDURE
   p_set_error
   ( pn_error IN CODLITERALES.SLITERA%TYPE, pn_sqlcode IN NUMBER, ps_sqlerrm IN VARCHAR2, ps_function IN VARCHAR2 )
IS
BEGIN
   VREG_AUDITAR.cusuari    := F_USER;
   VREG_AUDITAR.taccion    := VS_ACCION;
   VREG_AUDITAR.tfuncion   := SUBSTR(ps_function,1,30);
   VREG_AUDITAR.faccion    := SYSDATE;
   VREG_AUDITAR.err_lcode  := pn_error;
   VREG_AUDITAR.err_lerrm  := NULL;
   VREG_AUDITAR.err_sqlcode:= pn_sqlcode;
   VREG_AUDITAR.err_sqlerrm:= SUBSTR(ps_sqlerrm,1,255);
   -- Capturar el texto de literal (si es NL_TFDB_OK0 lo traducimos a NL_TFDB_OK_LIT)
   BEGIN
      SELECT
            tlitera
      INTO  VREG_AUDITAR.err_lerrm
      FROM  usuarios    u,
            literales   l
      WHERE u.cusuari   = F_USER
      AND   u.cidioma   = l.cidioma
      AND   l.slitera   = DECODE(pn_error, NL_TFDB_OK0, NL_TFDB_OK_LIT, pn_error )
            ;
      VREG_AUDITAR.err_lerrm := SUBSTR( VREG_AUDITAR.err_lerrm||': "'||ps_sqlerrm||'"', 1, 500 );
   EXCEPTION
   WHEN OTHERS THEN
      VREG_AUDITAR.err_lerrm  := SQLERRM;
   END;
-- dbg_print_errors;
END   p_set_error;
  -----------------------------------------------------------------------------
FUNCTION
   f_get_error
   RETURN   CODLITERALES.SLITERA%TYPE
IS
BEGIN
   RETURN   VREG_AUDITAR.err_lcode;
END   f_get_error;
  -----------------------------------------------------------------------------
PROCEDURE
   dbg_print_errors
IS
BEGIN
   DBMS_OUTPUT.PUT_LINE( RPAD('-',80,'-') );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.cusuari      '||VREG_AUDITAR.cusuari    );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.taccion      '||VREG_AUDITAR.taccion    );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.tfuncion     '||VREG_AUDITAR.tfuncion   );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.faccion      '||VREG_AUDITAR.faccion    );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.err_lcode    '||VREG_AUDITAR.err_lcode  );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.err_lerrm    '||VREG_AUDITAR.err_lerrm  );
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.err_sqlcode  '||VREG_AUDITAR.err_sqlcode);
   DBMS_OUTPUT.PUT_LINE('VREG_AUDITAR.err_sqlerrm  '||VREG_AUDITAR.err_sqlerrm);
END dbg_print_errors;



  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
END     pac_usuarios_adm;

/

  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "PROGRAMADORESCSI";
