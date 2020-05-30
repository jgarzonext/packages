--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTTABLAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTTABLAS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_MNTTABLAS
   PROPÓSITO:    Contiene los metodos y funciones para realizar el mantenimiento
                 de las tablas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/03/2008   JCA                1. Creación del package.
******************************************************************************/
    /*************************************************************************
       Función que recupera la lista de las tablas susceptibles de su
       mantenimiento

       param out mensajes     : colección de mensajes
       return sys_refcursor   : devolucion del cursor con los datos de la tabla
    *************************************************************************/

    e_object_error  exception;
    e_param_error   exception;

    mensajes T_IAX_MENSAJES;



    FUNCTION F_Get_Tablas (mensajes OUT T_IAX_MENSAJES)RETURN SYS_REFCURSOR IS
    cur SYS_REFCURSOR;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):=' ';
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_Get_Tablas';

    pcidioma NUMBER;
    nerr NUMBER;

    BEGIN

        nerr:= PAC_MD_COMMON.F_GET_CXTIDIOMA;
        vpasexec:=2;
        cur := PAC_MD_MNTTABLAS.F_Get_Tablas(nerr,mensajes);
        vpasexec:=3;

    RETURN cur;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    END F_Get_Tablas;

    /*************************************************************************
       Recupera los datos de la tabla especificada como parametro de entrada
       en la funcion y devuelve un cursor con los datos

       param in ptabla        : nombre de la tabla especificada
       param in out mensajes  : colección de mensajes
       return sys_refcursor   : devolucion del cursor con los datos de la tabla
    *************************************************************************/

    FUNCTION F_Get_Tabvalores(ptabla IN VARCHAR2,
                              mensajes OUT T_IAX_MENSAJES) RETURN SYS_REFCURSOR IS
    cur SYS_REFCURSOR;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):='ptabla='||ptabla;
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_Get_Tabvalores';

    BEGIN

    vpasexec:=2;
    cur := PAC_MD_MNTTABLAS.F_Get_Tabvalores(ptabla,mensajes);
    vpasexec:=3;

    RETURN cur;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    END F_Get_Tabvalores;

    /*************************************************************************
       Recupera los registros de la tabla detalle con relación al registro
       identificativo de la tabla principal
       param in ptabla        : Nombre de la tabla a consultar
       param in prelacion     : Lista de campos para realizar la condición sobre
                                la tabla detalle separados por ;
       param in pvalores      : valores de la tabla principal que relacionan con
                                el detalle separados por ;
       param in out mensajes  : colección de mensajes
       return sys_refcursor   : devolucion del cursor con los datos de la tabla
    *************************************************************************/

    FUNCTION F_Get_TabDetValores(ptabla IN VARCHAR2,
                                 prelacion IN VARCHAR2,
                                 pvalores IN VARCHAR2,
                                 mensajes OUT T_IAX_MENSAJES) RETURN SYS_REFCURSOR IS
    cur SYS_REFCURSOR;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(1000):='ptabla= '||ptabla||' prelacion= '||prelacion||' pvalores= '||pvalores;
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_Get_TabDetValores';

    BEGIN

        vpasexec:=2;
    cur := PAC_MD_MNTTABLAS.F_Get_TabDetvalores(ptabla,prelacion, pvalores, mensajes);
        vpasexec:=3;

    RETURN cur;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    END F_Get_TabDetValores;

    /*************************************************************************
       Recupera el cursor con los idiomas definidos en la aplicacion
       param in out mensajes  : colección de mensajes
       return sys_refcursor   : devolucion del cursor con los datos de la tabla
    *************************************************************************/
    FUNCTION F_Get_Idiomas(mensajes OUT T_IAX_MENSAJES) RETURN SYS_REFCURSOR IS
    cur SYS_REFCURSOR;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):=' ';
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_Get_Idiomas';

    BEGIN

    vpasexec:=2;
    cur := PAC_MD_MNTTABLAS.F_Get_Idiomas(mensajes);
    vpasexec:=3;


    RETURN cur;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN cur;
    END F_Get_Idiomas;


  /*************************************************************************
       Funcion que proporciona los mecanismos para leer el objeto y eliminar
       el registro especificado

       param in pobtabla      : objecto mantenimiento de tablas con la informacion
                                de la tabla y registro a eliminar
       param in out mensajes  : colección de mensajes
       return number          : 1 en caso de error
                              : 2 si OK
    *************************************************************************/

    FUNCTION F_eliminaregistro(pobtabla IN OB_IAX_MNTTABLAS,
                              mensajes OUT T_IAX_MENSAJES) RETURN NUMBER IS
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):=' ';
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_eliminaregistro';

    nerr NUMBER;
    psql VARCHAR2(2000);

    vversion OB_IAX_MNTREGISTROS;
    vmnttablas OB_IAX_MNTTABLAS;
    vregistros T_IAX_MNTREGISTROS;
    vtregistros VARCHAR2(2000);


    BEGIN

        -- control de mestre/detall
        psql:= 'delete from '||vmnttablas.ttabla;    -- FALTA TRATAR WHERE
        nerr:= PAC_MD_MNTTABLAS.F_ELIMINAREGISTRO (psql, mensajes);
    RETURN nerr;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END F_eliminaregistro;


  /*************************************************************************
       Funcion que proporciona los mecanismos para leer el objeto y modificar
       o insertar el registro especificado

       param in pobtabla      : objecto mantenimiento de tablas con la informacion
                                de la tabla y registro a modificar o insertar
       param in out mensajes  : colección de mensajes
       return number          : 1 en caso de error
                              : 2 si OK
    *************************************************************************/

    FUNCTION F_GrabaRegistros(pobtabla IN OB_IAX_MNTTABLAS,
                              mensajes OUT T_IAX_MENSAJES) RETURN NUMBER IS
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):=' ';
    vobject VARCHAR2(200):='PAC_IAX_MNTTABLAS.F_GrabarRegistros';
    nerr NUMBER;
    psql VARCHAR2(2000);
    vversion OB_IAX_MNTREGISTROS;
    vmnttablas OB_IAX_MNTTABLAS;
    vvalores OB_IAX_MNTREGISTRO;
    vregistro T_IAX_MNTREGISTRO;


    lv_appendstring LONG;
    lv_resultstring LONG;
    lv_count   NUMBER;
    lv_count2  NUMBER:=0;
    lwhere LONG:= ' ';
    lvalues LONG;
    lcampos LONG;

       BEGIN
        -- procedimiento para la where
        lv_count2:=0;
        lv_appendstring := vmnttablas.relacion||';';
       LOOP
        EXIT WHEN NVL(instr(lv_appendstring,';'),-99)<0;
            -- obtengo los campos
            lv_resultstring:=substr(lv_appendstring,1,(instr(lv_appendstring,';')-1));
            -- sólo pondrà and si hay más campos a relacionar
            if lv_count2 > 0 then
               lwhere:= lwhere||' and ';
            end if;
            -- hace la where con el campo a relacionar
            lwhere := lwhere||vmnttablas.ttabla||'.'||lv_resultstring||'='||vmnttablas.tabdetalle||'.'||lv_resultstring;
            -- contador para and
            lv_count2:= lv_count2 + 1;
            -- contador para relacion
            lv_count:=instr(lv_appendstring,';')+1;
            -- posiciono en el nuevo registro
            lv_appendstring:=substr(lv_appendstring,lv_count,length(lv_appendstring));
        END LOOP;
        -- procedimiento para registros recorriendo el objeto OB_IAX_MNTREGISTRO

        IF vversion.oldversion IS NULL THEN -- controla si es insert o update
           IF vmnttablas.tabdetalle IS NULL THEN -- controla si tiene detalle o no
              -- insert sin detalle
               psql:= 'INSERT INTO '||vmnttablas.ttabla||'('||vvalores.campo||' VALUES('||vvalores.valor; --INSERT
           ELSE
              -- insert con detalle
               psql:= 'INSERT INTO '||vmnttablas.tabdetalle||'('||vvalores.campo||' VALUES('||vvalores.valor; --INSERT
               -- FACTA TRACTAR WHERE
           END IF;
        ELSE
           IF vmnttablas.tabdetalle IS NULL THEN -- controla si tiene detalle o no
              -- update sin detalle
               psql:= 'UPDATE '||vmnttablas.ttabla||' SET '||vvalores.campo||'='||vvalores.valor||lwhere;  --update
           ELSE
              -- update con detalle
               psql:= 'UPDATE '||vmnttablas.tabdetalle||' SET '||vvalores.campo||'='||vvalores.valor||lwhere;  --update
               -- FALTA TRACTAR WHERE
           END IF;
        END IF;

        nerr:= PAC_MD_MNTTABLAS.F_GRABAREGISTROS (psql, mensajes);
    RETURN nerr;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        RETURN 1;
    END F_GrabaRegistros;

END PAC_IAX_MNTTABLAS;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTTABLAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTTABLAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTTABLAS" TO "PROGRAMADORESCSI";
