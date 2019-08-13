#!/usr/bin/env sh
usage ()
{
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
            if test -z "${1}" ; then
                echo "You must provide an image"
                usage
            fi
            image="${1}"
            ;;
        -t|--tag)
            shift
            if test -z "${1}" ; then
                echo "You must provide a docker tag"
                usage
            fi
            tag="${1}"
            ;;
        --dry-run)
            dryRun="echo"
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unrecognized option"
            usage
            ;;
    esac
    shift
done

docker pull ${image}
originalEntrypoint=$( docker image inspect ${image} --format '{{join .Config.Entrypoint " "}}' )
${dryRun} docker build \
    --build-arg "ORIGINAL_ENTRYPOINT=${originalEntrypoint}" \
    --build-arg "ORIGINAL_IMAGE=${image}" \
    ${tag+--tag }${tag} \
    .