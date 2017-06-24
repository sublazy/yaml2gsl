#include <yaml.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

int main(int argc, char *argv[])
{
    /* Initialization. */

    char buf[64];
    int help = 0;
    int canonical = 0;
    int unicode = 0;
    int k;
    int done = 0;

    yaml_parser_t parser;
    yaml_event_t input_event;

    /* Clear the objects. */

    memset(&parser, 0, sizeof(parser));
    memset(&input_event, 0, sizeof(input_event));

    /* Analyze command line options. */

    for (k = 1; k < argc; k ++)
    {
        if (strcmp(argv[k], "-h") == 0
                || strcmp(argv[k], "--help") == 0) {
            help = 1;
        }

        else if (strcmp(argv[k], "-c") == 0
                || strcmp(argv[k], "--canonical") == 0) {
            canonical = 1;
        }

        else if (strcmp(argv[k], "-u") == 0
                || strcmp(argv[k], "--unicode") == 0) {
            unicode = 1;
        }

        else {
            fprintf(stderr, "Unrecognized option: %s\n"
                    "Try `%s --help` for more information.\n",
                    argv[k], argv[0]);
            return 1;
        }
    }

    /* Display the help string. */

    if (help)
    {
        printf("%s <input\n"
                "or\n%s -h | --help\nDeconstruct a YAML stream\n\nOptions:\n"
                "-h, --help\t\tdisplay this help and exit\n"
                "-c, --canonical\t\toutput in the canonical YAML format\n"
                "-u, --unicode\t\toutput unescaped non-ASCII characters\n",
                argv[0], argv[0]);
        return 0;
    }

    /* Initialize the parser and emitter objects. */

    if (!yaml_parser_initialize(&parser)) {
        fprintf(stderr, "Could not initialize the parser object\n");
        return 1;
    }

    /* Set the parser parameters. */

    yaml_parser_set_input_file(&parser, stdin);

    /* Loop through the input events. */

    while (!done)
    {
        /* Get the next event. */

        if (!yaml_parser_parse(&parser, &input_event))
            goto parser_error;

        /* Check if this is the stream end. */

        if (input_event.type == YAML_STREAM_END_EVENT) {
            done = 1;
        }

        /* Analyze the event. */

        switch (input_event.type)
        {
            case YAML_STREAM_START_EVENT:

                /* Display encoding information. */

                if (input_event.data.stream_start.encoding)
                {
                    yaml_encoding_t encoding
                        = input_event.data.stream_start.encoding;
                }

                break;

            case YAML_STREAM_END_EVENT:

                break;

            case YAML_DOCUMENT_START_EVENT:

                break;

            case YAML_DOCUMENT_END_EVENT:

                break;

            case YAML_ALIAS_EVENT:

                break;

            case YAML_SCALAR_EVENT:

                bzero(buf, 64);
                snprintf(buf, input_event.data.scalar.length + 1,
                            input_event.data.scalar.value);

                printf("-> %s\n", buf);
                break;

            case YAML_SEQUENCE_START_EVENT:

                if (input_event.data.sequence_start.anchor)
                {
                }

                /* Display the sequence tag. */

                if (input_event.data.sequence_start.tag)
                {
                }

                break;

            case YAML_SEQUENCE_END_EVENT:

                break;

            case YAML_MAPPING_START_EVENT:

                if (input_event.data.mapping_start.anchor)
                {
                }

                if (input_event.data.mapping_start.tag)
                {
                }

                break;

            case YAML_MAPPING_END_EVENT:

                break;

            default:
                /* it couldn't really happen. */
                break;
        }

        /* delete the event object. */

        yaml_event_delete(&input_event);

    }

    yaml_parser_delete(&parser);

    return 0;

parser_error:

    /* display a parser error message. */

    switch (parser.error)
    {
        case YAML_MEMORY_ERROR:
            fprintf(stderr, "Memory error: Not enough memory for parsing\n");
            break;

        case YAML_READER_ERROR:
            if (parser.problem_value != -1) {
                fprintf(stderr, "Reader error: %s: #%X at %d\n", parser.problem,
                        parser.problem_value, parser.problem_offset);
            }
            else {
                fprintf(stderr, "Reader error: %s at %d\n", parser.problem,
                        parser.problem_offset);
            }
            break;

        case YAML_SCANNER_ERROR:
            if (parser.context) {
                fprintf(stderr, "Scanner error: %s at line %d, column %d\n"
                        "%s at line %d, column %d\n", parser.context,
                        parser.context_mark.line+1, parser.context_mark.column+1,
                        parser.problem, parser.problem_mark.line+1,
                        parser.problem_mark.column+1);
            }
            else {
                fprintf(stderr, "Scanner error: %s at line %d, column %d\n",
                        parser.problem, parser.problem_mark.line+1,
                        parser.problem_mark.column+1);
            }
            break;

        case YAML_PARSER_ERROR:
            if (parser.context) {
                fprintf(stderr, "Parser error: %s at line %d, column %d\n"
                        "%s at line %d, column %d\n", parser.context,
                        parser.context_mark.line+1, parser.context_mark.column+1,
                        parser.problem, parser.problem_mark.line+1,
                        parser.problem_mark.column+1);
            }
            else {
                fprintf(stderr, "Parser error: %s at line %d, column %d\n",
                        parser.problem, parser.problem_mark.line+1,
                        parser.problem_mark.column+1);
            }
            break;

        default:
            /* Couldn't happen. */
            fprintf(stderr, "Internal error\n");
            break;
    }

    yaml_event_delete(&input_event);
    yaml_parser_delete(&parser);

    return 1;
}


