
/* Autogenerated file, do not edit! */

/* eslint-disable */
import {
  AztecAddress,
  AztecAddressLike,
  CompleteAddress,
  Contract,
  ContractArtifact,
  ContractBase,
  ContractFunctionInteraction,
  ContractInstanceWithAddress,
  ContractMethod,
  DeployMethod,
  EthAddress,
  EthAddressLike,
  FieldLike,
  Fr,
  FunctionSelectorLike,
  loadContractArtifact,
  NoirCompiledContract,
  Point,
  PublicKey,
  Wallet,
  WrappedFieldLike,
} from '@aztec/aztec.js';
import LocalOracleContractArtifactJson from '../../target/context-LocalOracle.json' assert { type: 'json' };
export const LocalOracleContractArtifact = loadContractArtifact(LocalOracleContractArtifactJson as NoirCompiledContract);

/**
 * Type-safe interface for contract LocalOracle;
 */
export class LocalOracleContract extends ContractBase {
  
  private constructor(
    instance: ContractInstanceWithAddress,
    wallet: Wallet,
  ) {
    super(instance, LocalOracleContractArtifact, wallet);
  }
  

  
  /**
   * Creates a contract instance.
   * @param address - The deployed contract's address.
   * @param wallet - The wallet to use when interacting with the contract.
   * @returns A promise that resolves to a new Contract instance.
   */
  public static async at(
    address: AztecAddress,
    wallet: Wallet,
  ) {
    return Contract.at(address, LocalOracleContract.artifact, wallet) as Promise<LocalOracleContract>;
  }

  
  /**
   * Creates a tx to deploy a new instance of this contract.
   */
  public static deploy(wallet: Wallet, ) {
    return new DeployMethod<LocalOracleContract>(Point.ZERO, wallet, LocalOracleContractArtifact, LocalOracleContract.at, Array.from(arguments).slice(1));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified public key to derive the address.
   */
  public static deployWithPublicKey(publicKey: PublicKey, wallet: Wallet, ) {
    return new DeployMethod<LocalOracleContract>(publicKey, wallet, LocalOracleContractArtifact, LocalOracleContract.at, Array.from(arguments).slice(2));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified constructor method.
   */
  public static deployWithOpts<M extends keyof LocalOracleContract['methods']>(
    opts: { publicKey?: PublicKey; method?: M; wallet: Wallet },
    ...args: Parameters<LocalOracleContract['methods'][M]>
  ) {
    return new DeployMethod<LocalOracleContract>(
      opts.publicKey ?? Point.ZERO,
      opts.wallet,
      LocalOracleContractArtifact,
      LocalOracleContract.at,
      Array.from(arguments).slice(1),
      opts.method ?? 'constructor',
    );
  }
  

  
  /**
   * Returns this contract's artifact.
   */
  public static get artifact(): ContractArtifact {
    return LocalOracleContractArtifact;
  }
  

  /** Type-safe wrappers for the public methods exposed by the contract. */
  public methods!: {
    
    /** sqrt(input: array) */
    sqrt: ((input: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** get_sqrt(input: array) */
    get_sqrt: ((input: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** compute_note_hash_and_nullifier(contract_address: struct, nonce: field, storage_slot: field, note_type_id: field, serialized_note: array) */
    compute_note_hash_and_nullifier: ((contract_address: AztecAddressLike, nonce: FieldLike, storage_slot: FieldLike, note_type_id: FieldLike, serialized_note: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** constructor() */
    constructor: (() => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
  };
}
