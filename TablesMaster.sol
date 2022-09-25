// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@tableland/evm/contracts/TablelandTables.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract tablas is ERC721Holder {
    ITablelandTables internal _tableland;   //

    // Variables Tabla Comunidades
    string internal tableNameCom;       //Complete Name of the Table
    uint256 internal _tableIdCom;       //Id of the table on TableLand
    uint256 internal _counterCom;       //Counter for the if of the communities
        
    address internal _registry = 0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68; //Polygon Mumbai

    constructor() payable {
        _tableland = ITablelandTables(_registry);   
        _counterCom = 1000;                         //we initialize the counter
    }

    // Verifica que no se haya creado la tabla
    modifier tableExist(uint256 idtable) {
        bool exist = false;

        if (idtable != 0) exist=true;

        require(!exist, "This table has already been created");
        _;
    }

    //Creation of the table for store the communities
    function createTableCom() external payable tableExist(_tableIdCom) {
        _tableIdCom = _tableland.createTable(
            address(this),
            string.concat("CREATE TABLE ",
                "TrustedSphereCom",
                "_",
                Strings.toString(block.chainid),
                " (idCom int primary key, ComName text, City text, Country text, ComAddress1 text,",
                " Gps text, Units int, Fee int, ContractWallet text, AdminWallet text, Status int);"
            )
        );

        tableNameCom = string.concat(
            "TrustedSphereCom",
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdCom)
        );
    }

    //Add a new community to DB 
    function addCommunity(string memory _comName, string memory _city, string memory _country, string memory _addr, string memory _gps, uint _units, uint _fee,  address _adminWallet) external payable {

        _tableland.runSQL(
            address(this),  
            _tableIdCom,
           string.concat(
                "INSERT INTO ",
                tableNameCom,
                " (idCom, ComName, City, Country, ComAddress1, Gps, Units, Fee, ContractWallet, AdminWallet, Status) VALUES (",
                Strings.toString(_counterCom),
                ", '",
                _comName,
                "', '",
                _city,
                "', '",
                _country,
                "', '",
                _addr,
                "', '",
                _gps,
                "', ",
                Strings.toString(_units),
                ", ",
                Strings.toString(_fee),
                ", '', '",
                Strings.toHexString(uint256(uint160(_adminWallet)), 20),
                "', 1)"
            )
        );
        
        /********************************************/
        /* Crear contrato hijo de la comunidad      */
        /* llamando una funcion que lo haga y regrese el address del contrato hijo      */
        address _contractWallet = generateChild(_counterCom);

        // Update DB to register the contract address of the new community
        _tableland.runSQL(
            address(this),  
            _tableIdCom,
           string.concat(
                "UPDATE ",
                tableNameCom,
                " SET contractWallet='",
                Strings.toHexString(uint256(uint160(_contractWallet)), 20),
                "' WHERE idCom=",
                Strings.toString(_counterCom)
            )
        );
        _counterCom++;
    }

    //Generate new contract to the new community
    function generateChild(uint _community) internal returns(address) {
        //Fran haz tu magia!!
        //Para generar el contrato child se necesita en el constructor el _comunity y el address(this)
        return 0x711666202E9CCaeC45d7cd6aF786F661dfD36Bd6;
    }


}

/*******************************************************
/ OBSERVACIONES
/ Tenemos que hacer que al crear el contrato o hacer el deploy se ejecute
/ la funcion de createTableCom() lo intente en el constructor pero no se puede
/ igual se hace manual, pero por si acaso hay alguna otra forma
*/
