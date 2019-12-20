#!/usr/bin/env sh
usage ()
{
    if test -n "${1}" ; then
        echo $*
    fi
cat <<END_USAGE
Usage: build.sh {options}
    where {options} include:

    -i, --image
        Source Docker image to giterize
    -t, --tag
        Docker image tag for the produced image (default: none)
    -p, --prefix
        Prefix to use for the GIT environment variables in the produced image (default: GIT)
        The default will produce an image expecting GIT_URL, GIT_TAG and GIT_PATH.
    --dry-run
        does everything except actually call the docker command and prints it instead
    --help
        Display general usage information
END_USAGE
exit 99
}

showUsage=false

#
# Parse the provided arguments, if any
#
while ! test -z "${1}" ; do
    case "${1}" in
        -i|--image)
            shift
            if test -n "${1}" ; then
                image="${1}"
            else
                echo "You must provide a source image to giterize. Use -i or --image"
                showUsage=true
            fi
            ;;
        -t|--tag)
            shift
            if test -n "${1}" ; then
                tag="${1}"
            else
                echo "You must provide an image tag to giterize when specifying -t or --tag"
                showUsage=true
            fi
            ;;
        -p|--prefix)
            shift
            if test -n "${1}" ; then
                prefix="${1}"
            else
                echo "You must provide a prefix for the GIT environment variables when specifying -p or --prefix"
                showUsage=true
            fi
            ;;
        --dry-run)
            dryRun="echo"
            ;;
        --help)
            usage
            ;;
        *)
            usage "Unrecognized option"
            ;;
    esac
    shift
done

$showUsage && usage

docker pull ${image}
originalEntrypoint=$( docker image inspect ${image} --format '{{join .Config.Entrypoint " "}}' )
originalCmd=$( docker image inspect ${image} --format '{{join .Config.Cmd " "}}' )
${dryRun} docker build \
    --build-arg "ORIGINAL_ENTRYPOINT=${originalEntrypoint}" \
    --build-arg "ORIGINAL_CMD=${originalCmd}" \
    --build-arg "ORIGINAL_IMAGE=${image}" \
    ${prefix:+--build-arg GIT_PREFIX=${prefix}} \
    ${tag+--tag ${tag}} \
    .