
using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libbson"], :libbson),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/felipenoris/mongo-c-driver-builder/releases/download/v1.9.5"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libbson.v1.9.5.aarch64-linux-gnu.tar.gz", "b49515eacf613faf6bc7a8640b2b3b2f560b2c0dcb89b4dbe69ac285c533fe16"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/libbson.v1.9.5.arm-linux-gnueabihf.tar.gz", "c36e3631e57eff0f8c5d4b4735dcc299c7e92232383c035b45aeb368bbef1bc2"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libbson.v1.9.5.powerpc64le-linux-gnu.tar.gz", "d653cbd0ea0e56cebce143c2fb7bc87ae97eaf7dfec0b38a7294832a7526afdc"),
    MacOS(:x86_64) => ("$bin_prefix/libbson.v1.9.5.x86_64-apple-darwin14.tar.gz", "b91422553f1b69a818d910f63aafd5b8fc151543ed3562dcb18524aedbed242c"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/libbson.v1.9.5.x86_64-linux-gnu.tar.gz", "c47592728fa0301871d09a84e4f5f3a97cbd39e679fdfd2c249c1f2763be7074"),
    FreeBSD(:x86_64) => ("$bin_prefix/libbson.v1.9.5.x86_64-unknown-freebsd11.1.tar.gz", "31587d9c9270c154af148b716a8033a646cdd0ecd26f51379c2818b5294945ec"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
