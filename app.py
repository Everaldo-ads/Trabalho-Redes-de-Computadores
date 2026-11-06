import os
from datetime import date

import mysql.connector
import streamlit as st


MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3310"))
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "rootpassword")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "streamlit_app")


def get_server_connection():
    return mysql.connector.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        autocommit=True,
    )


def ensure_database_and_table():
    conn = get_server_connection()
    cursor = conn.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{MYSQL_DATABASE}`")
    cursor.execute(f"USE `{MYSQL_DATABASE}`")
    cursor.execute(
        f"""
        CREATE TABLE IF NOT EXISTS `eventos` (
            id INT AUTO_INCREMENT PRIMARY KEY,
            evento VARCHAR(255) NOT NULL,
            data_evento DATE NOT NULL,
            criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    conn.commit()
    cursor.close()
    conn.close()


def insert_evento(evento: str, data_evento: date):
    conn = mysql.connector.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        database=MYSQL_DATABASE,
        autocommit=True,
    )
    cursor = conn.cursor()
    sql = "INSERT INTO eventos (evento, data_evento) VALUES (%s, %s)"
    cursor.execute(sql, (evento, data_evento.strftime("%Y-%m-%d")))
    conn.commit()
    cursor.close()
    conn.close()


st.set_page_config(page_title="Cadastro de Eventos", page_icon="📅", layout="centered")

ensure_database_and_table()

st.title("Cadastro de Eventos")
st.caption("Dados salvos no schema do MySQL: streamlit_app")

with st.form("evento_form"):
    evento = st.text_input("Evento", placeholder="Ex.: Palestra de Docker")
    data_evento = st.date_input("Data", value=date.today())
    submitted = st.form_submit_button("Salvar evento")

if submitted:
    if not evento.strip():
        st.warning("Informe o nome do evento antes de salvar.")
    else:
        insert_evento(evento.strip(), data_evento)
        st.success("Evento salvo com sucesso!")

st.subheader("Registros")

conn = mysql.connector.connect(
    host=MYSQL_HOST,
    port=MYSQL_PORT,
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    database=MYSQL_DATABASE,
    autocommit=True,
)
cursor = conn.cursor()
cursor.execute("SELECT evento, data_evento, criado_em FROM eventos ORDER BY criado_em DESC")
rows = cursor.fetchall()

if rows:
    st.dataframe(
        [
            {
                "Evento": evento,
                "Data": data_evento.strftime("%d/%m/%Y"),
                "Criado em": criado_em,
            }
            for evento, data_evento, criado_em in rows
        ],
        use_container_width=True,
    )

    st.subheader("Lista de itens no banco")
    for evento, data_evento, criado_em in rows:
        st.markdown(
            f"- **{evento}** | Data: {data_evento.strftime('%d/%m/%Y')} | Salvo em: {criado_em}"
        )
else:
    st.info("Nenhum evento cadastrado até o momento.")

cursor.close()
conn.close()
