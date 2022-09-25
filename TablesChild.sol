// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@tableland/evm/contracts/TablelandTables.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Child is ERC721Holder {
    
    mapping(address => uint) public Units;
    mapping(uint => address) Supliers;
    address admin;      //Administrador de la comunidad
    uint community;     //Id de Comunidad **** Como la hacemos constante??
    address MasterContract;     //address del contrato padre, siempre constante
    // address del contrato de mumbai polygon, debe ser variable para cambiarlo faciul de red, pero por lo pronto asi esta mas facil
    address _registry = 0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68;     //Polygon Mumbai
    
    ITablelandTables internal _tableland; 
    // Variables Tabla Units(Casas)
    string internal tableNameUnit;
    uint256 internal _tableIdUnit;
    uint internal counterUnit;
    // Variables Tabla Payments
    string internal tableNamePay;
    uint256 internal _tableIdPay;
    uint internal counterPay;
    // Variables Tabla Suppliers
    string internal tableNameSup;
    uint256 internal _tableIdSup;
    uint internal counterSup;
    // Variables Tabla Suppliers Payments
    string internal tableNameSP;
    uint256 internal _tableIdSP;
    uint internal counterSP;

    constructor(uint _community, address _masterContract) {
        community = _community;
        MasterContract = _masterContract;
        _tableland = ITablelandTables(_registry);

        counterUnit = 1;
        counterPay=1;
        counterSup=1;
        counterSP=1;
    }

    // Verifica que sea miembro de la comunidad
    modifier requireMember() {
        bool isMember = false;
        uint unit;

        unit = Units[msg.sender];
        if (unit != 0) isMember=true;

        require(isMember, "Tu Wallet no esta dada de alta en esta comunidad");
        _;
    }

    // Verifica que no se haya creado la tabla
    modifier tableExist(uint256 idtable) {
        bool exist = false;

        if (idtable != 0) exist=true;

        require(!exist, "Esta Tabla ya fue creada");
        _;
    }

    function createTableUnit() external payable tableExist(_tableIdUnit) {
        _tableIdUnit = _tableland.createTable(
            address(this),
            /* CREATE TABLE prefix_chainId (id int primary key, message text); */
            string.concat("CREATE TABLE ",
                "TrustedSphereUnit",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idUnit int primary key, idCom int, NumUnit int, NameOwner text, Status int);"
            )
        );

        tableNameUnit = string.concat(
            "TrustedSphereUnit",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdUnit)
        );
    }

    function createTablePayments() external payable tableExist(_tableIdPay) {
        _tableIdPay = _tableland.createTable(
            address(this),
            /* CREATE TABLE prefix_chainId (id int primary key, message text); */
            string.concat("CREATE TABLE ",
                "TrustedSpherePay",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idPay int primary key, idUnit int, Fee int, Year int, Month int, date text, Status int);"
            )
        );

        tableNamePay = string.concat(
            "TrustedSpherePay",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdPay)
        );
    }

    function createTableSuppliers() external payable tableExist(_tableIdSup) {
        _tableIdSup = _tableland.createTable(
            address(this),
            /* CREATE TABLE prefix_chainId (id int primary key, message text); */
            string.concat("CREATE TABLE ",
                "TrustedSphereSup",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idSup int primary key, idCom int, SupName text, amount int, day int, status int);"
            )
        );

        tableNameSup = string.concat(
            "TrustedSphereSup",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdSup)
        );
    }

    function createTableSupPayments() external payable tableExist(_tableIdSP) {
        _tableIdSP = _tableland.createTable(
            address(this),
            /* CREATE TABLE prefix_chainId (id int primary key, message text); */
            string.concat("CREATE TABLE ",
                "TrustedSphereSP",
                Strings.toString(community),
                "_",
                Strings.toString(block.chainid),
                " (idSP int primary key, idSup int, amount int, year int, month int, date text, status int);"
            )
        );

        tableNameSP = string.concat(
            "TrustedSphereSP",
            Strings.toString(community),
            "_",
            Strings.toString(block.chainid),
            "_",
            Strings.toString(_tableIdSP)
        );
    }

    //Add a new unit to de DB and the mapping "Units"
    function addUnit(uint _num, string memory _name, address _ownerW) external payable {
        Units[_ownerW] = _num;

        _tableland.runSQL(
            address(this),  //revisar si es esta address o tienes que ser la del padre
            _tableIdUnit,
           string.concat(
                "INSERT INTO ",
                tableNameUnit,
                " (idunit, idcom, numunit, nameowner, status) VALUES (",
                Strings.toString(counterUnit),
                ", ",
                Strings.toString(community),
                ", ",
                Strings.toString(_num),
                ", '",
                _name,
                "', 1)"
            )
        );
        counterUnit++;
    }

    function deposit(uint _unit, uint _fee, uint _year, uint _month) public payable requireMember {
        //Save to DB
         _tableland.runSQL(
            address(this),
            _tableIdPay,
           string.concat(
                "INSERT INTO ",
                tableNamePay,
                " (idPay, idUnit, Fee, Year, Month, date, status) VALUES (",
                Strings.toString(counterPay),
                ", ",
                Strings.toString(_unit),
                ", ",
                Strings.toString(_fee),
                ", ",
                Strings.toString(_year),
                ", ",
                Strings.toString(_month),
                ", ",
                Strings.toString(block.timestamp),
                ", 1)"
            )
        );
        counterPay++;

        generateNFT(_unit, _year, _month);
    }

    function generateNFT (uint _unit, uint _year, uint _month) internal returns (bool) {
        //code
    }

    // This function have to be from frontend with the tableland API
    /*function getLastMonth(address _user) view returns (uint, uint) {
    }*/

    function addSuplier(string memory _name, uint _amount, address _supWallet, uint _day) external payable {
        Supliers[counterSup]=_supWallet;

        //Save to DB
         _tableland.runSQL(
            address(this),  
            _tableIdSup,
           string.concat(
                "INSERT INTO ",
                tableNameSup,
                " (idSup, idCom, SupName, amount, day, status) VALUES (",
                Strings.toString(counterSup),
                ", ",
                Strings.toString(community),
                ", '",
                _name,
                "', ",
                Strings.toString(_amount),
                ", ",
                Strings.toString(_day),
                ", 1)"
            )
        );
        counterSup++;
    }

    //returns the contract balance (community balance)
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function suplierPaymen(uint _idSup, uint _amount, uint _year, uint _month) external {

        require(address(this).balance>_amount, "Not enough money!!");

        address supWallet = Supliers[_idSup];

        (bool resultado, bytes memory salida) = supWallet.call{value:_amount}("");
        require(resultado, "nos fallo esta madre");

        //Save to DB
         _tableland.runSQL(
            address(this), 
            _tableIdSP,
           string.concat(
                "INSERT INTO ",
                tableNameSP,
                " (idSP, idSup, amount, year, month, date, status) VALUES (",
                Strings.toString(counterSP),
                ", ",
                Strings.toString(_idSup),
                ", ",
                Strings.toString(_amount),
                ", ",
                Strings.toString(_year),
                ", ",
                Strings.toString(_month),
                ", '",
                Strings.toString(block.timestamp),
                "', 1)"
            )
        );
        counterSP++;
    }

    //Regresa la Unit del usuario que ingreso a la dapp, si es 0 no esta dado de alta
    function getUnit() public view returns(uint256) {
        return Units[msg.sender];
    }
} 


/******************************************************************************************
  ACLARACIONES 
  No se esta revisando todavia duplicados en numero de units, wallets, supplieres, etc...
  */
