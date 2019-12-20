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
        Docker image to giterize
    --dry-run
        does everything except actually call the docker command and prints it instead
    --help
        Display general usage information
END_USAGE
exit 99
}

#
# Parse the provided arguments, if any
#
while ! test -z "${1}" ; do
    case "${1}" in
        -i|--image)
            shift
            if test -n "${1}" ; then
                image="${1}"
            fi
            ;;
        -t|--tag)
            shift
            if test -z "${1}" ; then
                tag="${1}"
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

showUsage=false
if test -z "${image}" ; then
    echo "You must provide a source image to giterize. Use -i or --image"
    showUsage=true
fi
if test -z "${tag}" ; then
    echo "You must provide an image tag to giterize when specifying -t or --tag"
    showUsage=true
fi

$showUsage && usage

docker pull ${image}
originalEntrypoint=$( docker image inspect ${image} --format '{{join .Config.Entrypoint " "}}' )
originalCmd=$( docker image inspect ${image} --format '{{join .Config.Cmd " "}}' )
${dryRun} docker build \
    --build-arg "ORIGINAL_ENTRYPOINT=${originalEntrypoint}" \
    --build-arg "ORIGINAL_CMD=${originalCmd}" \
    --build-arg "ORIGINAL_IMAGE=${image}" \
    ${tag+--tag }${tag} \
    .