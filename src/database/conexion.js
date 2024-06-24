import sql from 'mssql';

//Datos para conectar la base de datos
const dbSettings = {
    user: "Davistranger",
    password: "tienda1-2<>",
    server: "localhost",
    database: "webstore",
    options: {
        encrypt: false,
        trustServerCertifiate: true,
    }
};

// constante para exportar la conexion a index
export const getConnection = async() => {
    try{
        const pool = await sql.connect(dbSettings);
        return pool;
    }   catch (error) {
        console.error(error);
    }
};