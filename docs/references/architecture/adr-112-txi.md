# ADR 112: Modular transaction hashing

## Changelog

- 2024-02-05: First version (@melekes)

## Status

TBD

## Context

Transaction hashing in CometBFT is currently implemented using `tmhash`
package, which itself relies on `sha256` to calculate a transaction's hash.

The hash is then used to calculate various hashes in CometBFT (e.g., tx,
evidence, consensus params), by the built-in indexer (to index this
transaction) and by the RPC `tx` and `tx_search` endpoints, which allow users
to search for a transaction using a hash.

The problem some application developers are facing is a mismatch between the
internal/app representation of transactions and the one employed by CometBFT. For
example, [Evmos](https://evmos.org/) wants transactions to be hashed using
the [RLP][rlp].

In order to be flexible, CometBFT needs to allow changing the hashing algorithm
if desired by the app developers.

## Alternative Approaches

None.

## Decision

Give app developers a way to provide their own hash function.

## Detailed Design

Add `hashFn HashFn` argument to `NewNode` constructor in `node.go`.

```go
type HashFn interface {
    // New returns a new hash.Hash calculating the given hash function.
    New() hash.Hash
    // Size returns the length, in bytes, of a digest resulting from the given hash function.
    Size() int
}

type TMHash struct {}
func (TMHash) New() hash.Hash {
    return tmhash.New()
}
func (TMHash) Size(bz []byte) {
    return tmhash.Size
}

func DefaultHashFn() HashFn {
    return TMHash{}
}
```

And then use it to calculate a transaction's hash, consensus parameters hash, etc.

## Consequences

### Positive

- Modular transaction hashing
- Paving a way for the pluggable cryptography

### Negative

- One more argument in `NewNode`

### Neutral

## References

- [Original issue](https://github.com/tendermint/tendermint/issues/6539)

- [rlp]: https://ethereum.org/developers/docs/data-structures-and-encoding/rlp
