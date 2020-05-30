--------------------------------------------------------
--  DDL for Package Body PAC_IOBJ_MENSAJES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IOBJ_MENSAJES" AS
/******************************************************************************
   NOMBRE:      PAC_IOBJ_MENSAJES
   PROPÓSITO:   Funciones para la gestion de error y avisos de la aplicación

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2008   ACC               1. Creación del package.
******************************************************************************/

    --Funcions internes
    /*************************************************************************
        Comproba si el parametre
        return : 2 es valor numerico
                 1 alfanumerico
    *************************************************************************/
    FUNCTION isNumeric(var IN VARCHAR2) RETURN NUMBER IS
        n NUMBER;
    BEGIN

       n :=LENGTH(TRIM(TRANSLATE(var, ' +-.0123456789', ' ')));

       IF n is null THEN
          RETURN 2;
       END IF;

       RETURN 1;
    EXCEPTION WHEN OTHERS THEN
       RETURN 1;
    END;
    -------------------------

    /*************************************************************************
       Graba los errores que se produzcan en la base de datos
       param in ptobjeto  : objeto que produce el error
       param in pntraza   : número de traza
       param in ptdescrip : descripcón error
       param in pterror   : mensaje error
    *************************************************************************/
    PROCEDURE P_GrabaDBError (ptobjeto IN VARCHAR2, pntraza IN NUMBER,
                           ptdescrip IN VARCHAR2, pterror IN VARCHAR2) IS
    BEGIN
        PAC_MD_COMMON.P_Grabadberror(ptobjeto,pntraza,ptdescrip,pterror);
    END P_GrabaDBError;


    /*************************************************************************
       Devuelve el objeto mensaje
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in idioma   : código del idioma del mensaje
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
       return            : objeto mensajes
    *************************************************************************/
    FUNCTION F_Set_Mensaje(tipo number,nerror number,idioma number,
                        mensaje varchar2 DEFAULT '*') RETURN OB_IAX_MENSAJES IS

        ERR OB_IAX_MENSAJES:= OB_IAX_MENSAJES();
        terror varchar2(4000);
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(1000):='parametros: tipo '||tipo||'nerror ' ||nerror||
                               ' mensaje '||mensaje||' idioma '||idioma;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.F_Set_Mensaje';
    BEGIN
        ERR.tiperror:=tipo;
        ERR.cerror:=nerror;
        terror:= substr(mensaje,0,4000);
        IF terror='*' THEN
            vpasexec:=2;
            terror:= F_AXIS_LITERALES(nerror,idioma);
            IF NVL(terror,'####')='####' THEN -- NO S'HA TROBAT LITERAL
                terror:= '¿¿'||nerror||'??';
            END IF;
        END IF;
        ERR.terror:=terror;
        RETURN ERR;
    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
        RETURN NULL;
    END;

    /*************************************************************************
       Devuelve el literal del código de error
       param in cerror   : código de error
       param in idioma   : código del idioma del mensaje
       return            : texto del mensaje de error
    *************************************************************************/
    FUNCTION F_Get_DescMensaje(cerror IN NUMBER, idioma IN NUMBER) RETURN VARCHAR IS
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(1000):='parametros: cerror ' ||cerror||' idioma '||idioma;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.F_Get_DescMensaje';
        TERROR VARCHAR2(4000);
    BEGIN

        TERROR:= F_AXIS_LITERALES(cerror,idioma);

        IF NVL(terror,'####')='####' THEN -- NO S'HA TROBAT LITERAL
            terror:= '¿¿'||cerror||'??';
        END IF;

        RETURN TERROR;

    EXCEPTION WHEN OTHERS THEN
       P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
       RETURN NULL;
    END;

    /*************************************************************************
       Devuelve el literal del código de error
       param in cerror   : código de error
       return            : texto del mensaje de error
    *************************************************************************/
    FUNCTION F_Get_DescMensaje(cerror IN NUMBER) RETURN VARCHAR IS
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(1000):='parametros: cerror ' ||cerror;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.F_Get_DescMensaje';
        idioma NUMBER:=PAC_MD_COMMON.F_GET_CXTIDIOMA();
    BEGIN
        RETURN F_Get_DescMensaje(cerror,idioma);
    EXCEPTION WHEN OTHERS THEN
       P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
       RETURN NULL;
    END;

    /*************************************************************************
       Hace un merge en dos colecciones de mensajes
       param in mensajesDst : coleccion mensajes destino
       param in mensajes    : coleccion mensajes a merge
    *************************************************************************/
    PROCEDURE P_MergeMensaje(mensajesDst IN OUT T_IAX_MENSAJES, mensajes in T_IAX_MENSAJES) IS
    BEGIN
        IF mensajes is not null THEN
            IF mensajes.count>0 THEN
                IF mensajesDst is null THEN
                    mensajesDst := T_IAX_MENSAJES();
                END IF;
                FOR vmj IN mensajes.first..mensajes.last LOOP
                    mensajesDst.extend;
                    mensajesDst(mensajesDst.last) := mensajes(vmj);
                END LOOP;
            END IF;
        END IF;
    END P_MergeMensaje;

    /*************************************************************************
       Trata mensajes de error para excepciones
       param in out mensajes    : coleccion mensajes
       param in pfuncion         : nombre de la función
       param in pnerror          : número de error
       param in ptraza           : número de traza
       param in pparams          : parametros de la función
       param in pterror          : texto del mensaje a concatenar
       param in psqcode          : número error sqlcode
       param in psqerrm          : mensaje error sqlerrm
    *************************************************************************/
    PROCEDURE P_TratarMensaje(mensajes IN OUT T_IAX_MENSAJES,
                              pfuncion  IN VARCHAR2,
                              pnerror   IN NUMBER,
                              ptraza    IN NUMBER,
                              pparams   IN VARCHAR,
                              pterror   IN VARCHAR2 DEFAULT NULL,
                              psqcode   IN NUMBER DEFAULT NULL,
                              psqerrm   IN VARCHAR2 DEFAULT NULL) IS

        terror      VARCHAR2(2000);
        vpasexec    NUMBER(8):=1;
        vparam      VARCHAR2(2000):='pfuncion='||pfuncion||' nerror ' ||pnerror||' terror '||pterror||' sqcode '||psqcode||' sqerrm '||psqerrm;
        vobject     VARCHAR2(200):='PAC_IOBJ_MENSAJES.P_TratarMensaje';

    BEGIN

        vpasexec:=2;
        terror := F_Get_DescMensaje(pnerror,PAC_MD_COMMON.F_GET_CXTIDIOMA());
        IF NVL(pterror,' ')<>' ' THEN
            terror:= SUBSTR(terror||pterror,1,2000);
        END IF;

        vpasexec := 3;

        --(JAS)13.06.2008 - Gravem sempre l'error a BD.
        IF NVL(psqcode,0)=0 THEN
            P_GrabaDBError(pfuncion, ptraza, pparams,terror);
        ELSE
            P_GrabaDBError(pfuncion, ptraza, pparams,psqcode||'-'||psqerrm);
        END IF;

        vpasexec := 5;

        IF mensajes is not null THEN
            IF mensajes.count=0 THEN
                IF NVL(psqcode,0)=0 THEN
                    vpasexec:=7;
                    Crea_Nuevo_Mensaje(mensajes,1,pnerror,pfuncion||': '||terror);
                ELSE
                    vpasexec:=9;
                    Crea_Nuevo_Mensaje(mensajes,1,pnerror,pfuncion||': '||terror);
                    Crea_Nuevo_Mensaje(mensajes,1,psqcode,psqcode||'-'||psqerrm);
                END IF;
            END IF;
        ELSE
            IF NVL(psqcode,0)=0 THEN
                vpasexec:=11;
                Crea_Nuevo_Mensaje(mensajes,1,pnerror,pfuncion||': '||terror);
            ELSE
                vpasexec:=13;
                Crea_Nuevo_Mensaje(mensajes,1,pnerror,pfuncion||': '||terror);
                Crea_Nuevo_Mensaje(mensajes,1,psqcode,psqcode||'-'||psqerrm);
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
        Crea_Nuevo_Mensaje(mensajes,1,sqlcode,vobject||': '||sqlcode||'-'||sqlerrm);
    END P_TratarMensaje;

    /*************************************************************************
       Crea un registro nuevo de error
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje(mens IN OUT T_IAX_MENSAJES,
                   tipo number, nerror number, mensaje varchar2  DEFAULT '*') IS
        idioma number := PAC_MD_COMMON.F_GET_CXTIDIOMA();
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(1000):='parametros: tipo '||tipo||'nerror ' ||nerror||
                               ' mensaje '||mensaje||' idioma '||idioma;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje';
    BEGIN
        IF mens is null THEN
            mens := T_IAX_MENSAJES();
        END IF;
        mens.extend;
        mens(mens.last):= F_Set_Mensaje(tipo,nerror,idioma,mensaje);
    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
    END;

    /*************************************************************************
       Crea un registro nuevo de error compuestos
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in varmsg   : colección de variables a sustituir en el texto
                            del mensaje
       param in separador: como se limita el valor sustituir
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje_Var(mens IN OUT T_IAX_MENSAJES,
                     tipo number, nerror number, varmsg T_IAX_MSGVARIABLES,
                     separador varchar2 DEFAULT '$', mensaje varchar2 DEFAULT '*') IS

        smsg VARCHAR2(4000);
        idioma NUMBER := PAC_MD_COMMON.F_GET_CXTIDIOMA();
        vpasexec NUMBER(8):=1;
        vparam VARCHAR2(1000):='parametros: tipo '||tipo||'nerror ' ||nerror||
                               ' mensaje '||mensaje||' idioma '||idioma;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje_Var';
    BEGIN

        Crea_Nuevo_Mensaje(mens,tipo,nerror,mensaje);

        IF varmsg is not null THEN
            IF varmsg.count>0 THEN
                FOR i IN varmsg.first..varmsg.last LOOP
                    IF varmsg(i).tipo=1 THEN
                        smsg := varmsg(i).desvar;
                    ELSIF varmsg(i).tipo=2 THEN
                        vpasexec:=2;
                        smsg := F_Get_DescMensaje(varmsg(i).desvar,idioma); --F_AXIS_Literales(varmsg(i).desvar,idioma);
                        IF smsg is null then
                            smsg:=varmsg(i).desvar;
                        END IF;
                    END IF;
                    vpasexec:=3;

                    mens(mens.last).terror := replace(mens(mens.last).terror,separador||i,smsg);

                END LOOP;
            END IF;
        END IF;

    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
    END;

    /*************************************************************************
       Crea un registro nuevo de error compuestos
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in varmsg   : String con los elementos de la variables
       param in ptipo    : para la variables indicadas són del tipo DEFAULT NULL
                            1 varchar   2 codigo literal
       param in separador: como se limita el valor sustituir
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje_Var(mens IN OUT T_IAX_MENSAJES,
                     tipo number, nerror number, varmsg varchar2,ptipo IN NUMBER DEFAULT NULL,
                     separador varchar2 DEFAULT '$',mensaje varchar2 DEFAULT '*') IS

        smsg VARCHAR2(4000);
        idioma NUMBER := PAC_MD_COMMON.F_GET_CXTIDIOMA();
        vpasexec NUMBER(8):=1;
        tvarmsg T_IAX_MSGVARIABLES;
        vparam VARCHAR2(2000):='parametros: tipo '||tipo||'nerror ' ||nerror||
                               ' mensaje '||mensaje||' idioma '||idioma||' varmsg '||varmsg;
        vobject VARCHAR2(200):='PAC_IOBJ_MENSAJES.Crea_Nuevo_Mensaje_Var';
    BEGIN

        tvarmsg:= Crea_Variables_Mensaje(varmsg,ptipo);

        Crea_Nuevo_Mensaje_Var(mens,tipo,nerror,tvarmsg,separador,mensaje);

    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
    END;


    /*************************************************************************
       Crea el objeto variables de mensajes a partir del parametro
       param in variables : variables separadas por #
       param in ptipo     : para la variables indicadas són del tipo DEFAULT NULL
                            1 varchar   2 codigo literal
       return             : objeto variables de mensajes
    *************************************************************************/
    FUNCTION Crea_Variables_Mensaje(variables IN VARCHAR2,
                                    ptipo IN NUMBER DEFAULT NULL) RETURN T_IAX_MSGVARIABLES IS
        vpasexec NUMBER(8):=1;
        vparam   VARCHAR2(1000):='variables '||SUBSTR(variables,1,990);
        vobject  VARCHAR2(200):='PAC_IOBJ_MENSAJES.Crea_Variables_Mensaje';

        lv_appendstring LONG;
        lv_resultstring LONG;
        lv_count   NUMBER;
        msgvar T_IAX_MSGVARIABLES:=T_IAX_MSGVARIABLES();
    BEGIN

        IF variables is null THEN
            RETURN NULL;
        END IF;

        lv_appendstring := variables||'#';
        LOOP
        EXIT WHEN NVL(instr(lv_appendstring,'#'),-99)<0;
            lv_resultstring:=substr(lv_appendstring,1,(instr(lv_appendstring,'#')-1));
            lv_count:=instr(lv_appendstring,'#')+1;
            lv_appendstring:=substr(lv_appendstring,lv_count,length(lv_appendstring));

            IF NVL(lv_resultstring,'##NULL##')<>'##NULL##' THEN
                msgvar.extend;
                msgvar(msgvar.last):=OB_IAX_MSGVARIABLES();
                IF ptipo is null THEN
                    msgvar(msgvar.last).tipo:= isNumeric(lv_resultstring);
                ELSE
                    msgvar(msgvar.last).tipo:=ptipo;
                END IF;
                msgvar(msgvar.last).desvar:= substr(lv_resultstring,1,100);
            END IF;

        END LOOP;

        RETURN msgvar;
    EXCEPTION WHEN OTHERS THEN
        P_GrabaDBError(vobject,vpasexec,vparam,sqlcode||'-'||sqlerrm);
    END Crea_Variables_Mensaje;

END PAC_IOBJ_MENSAJES;

/

  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "PROGRAMADORESCSI";
