--------------------------------------------------------
--  DDL for Package Body PAC_MD_MNTTABLAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MNTTABLAS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_MNTTABLAS
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

       param IN  pcidioma     : codigo de idioma
       param out mensajes     : colección de mensajes
       return sys_refcursor   : devolucion del cursor con los datos de la tabla
    *************************************************************************/

    e_object_error  exception;
    e_param_error   exception;

    mensajes T_IAX_MENSAJES;

   FUNCTION F_Get_Tablas (pcidioma IN NUMBER, mensajes OUT T_IAX_MENSAJES)RETURN SYS_REFCURSOR IS
    cur SYS_REFCURSOR;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):='pcidioma='||pcidioma;
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_Get_Tablas';
   -- terror VARCHAR2(200):='Error al recuperar las tablas';

    BEGIN

        vpasexec:=2;
    cur:= PAC_MD_LISTVALORES.F_OpenCursor('select all from mnt_tablas m, mnt_tablasdes n '||
                            ' where n.cidioma ='|| pcidioma ||
                            ' and n.ctabla = m.ctabla', mensajes);
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
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_Get_Tabvalores';
  --  terror VARCHAR2(200):='Error al recuperar los valores';

    BEGIN
        vpasexec:=2;

    cur:= PAC_MD_LISTVALORES.F_OpenCursor('select all from'||ptabla, mensajes);

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
    vparam VARCHAR2(100):='ptabla='||ptabla||' prelacion= '||prelacion||' pvalores= '||pvalores;
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_Get_TabDetValores';
  --  terror VARCHAR2(200):='Error al recuperar los valores';

    BEGIN

        vpasexec:=2;

    cur:= PAC_MD_LISTVALORES.F_OpenCursor('select all from'||ptabla, mensajes);

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
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):=' ';
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_Get_Idiomas';
  --  terror VARCHAR2(200):='Error al obtener los idiomas';
    cur SYS_REFCURSOR;
    nerr NUMBER;

    BEGIN

        vpasexec:=2;

        cur:= PAC_MD_LISTVALORES.F_Get_LstIdiomas(mensajes);

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

       param in psql          : Instruccion sql a ejecutar
       param in out mensajes  : colección de mensajes
       return number          : 1 en caso de error
                              : 2 si OK
    *************************************************************************/

    FUNCTION F_eliminaregistro(psql IN VARCHAR2,
                               mensajes OUT T_IAX_MENSAJES) RETURN NUMBER IS

    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(1000):='psql='||psql;
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_eliminaregistro';
    cur SYS_REFCURSOR;

    BEGIN
   -- executar instrucció psql
        vpasexec:=2;
        OPEN cur for psql;
        RETURN 0;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
         IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;
   WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;

    END F_eliminaregistro;


  /*************************************************************************
       Funcion que proporciona los mecanismos para leer el objeto y modificar
       o insertar el registro especificado

       param in psql          : Instruccion sql a ejecutar
       param out mensajes     : mensajes de salida
       return number          : 1 en caso de error
                              : 2 si OK
    *************************************************************************/

    FUNCTION F_GrabaRegistros(psql IN VARCHAR2,
                              mensajes OUT T_IAX_MENSAJES) RETURN NUMBER IS
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(100):='psql='||psql;
    vobject VARCHAR2(200):='PAC_MD_MNTTABLAS.F_GrabarRegistros';
    cur SYS_REFCURSOR;

    BEGIN
    -- executar instrucció psql
       vpasexec:=2;
        RETURN 0;
    EXCEPTION
    WHEN e_param_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000006,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;
    WHEN e_object_error THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000005,vpasexec,vparam);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;
    WHEN OTHERS THEN
        PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
                1000001,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
        IF cur%isopen THEN CLOSE cur; END IF;
        RETURN 1;
    END F_GrabaRegistros;

END PAC_MD_MNTTABLAS;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTTABLAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTTABLAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTTABLAS" TO "PROGRAMADORESCSI";
