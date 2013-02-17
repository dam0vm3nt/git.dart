part of hop;

const String _hopCmdName = 'hop';

Task getHelpTask() {
  return new Task.sync((TaskContext ctx) {
    final args = ctx.arguments;

    if(args.command != null) {
      _printHelpForTask(_sharedConfig, args.command.name);
      return true;
    } else {

      _printHelp(_sharedConfig);

      if(!args.rest.isEmpty) {
        ctx.severe('Not sure how to give help for: ${args.rest}');
        return false;
      }

      return true;
    }
  },
  description: 'Print help information about available tasks',
  config: (parser) => _helpParserConfig(_sharedConfig, parser),
  extendedArgs: [new TaskArgument('task-name')]);
}

void _printHelpForTask(BaseConfig config, String taskName) {
  final task = config._getTask(taskName);
  assert(task != null);

  final usage = task.getUsage();

  _printUsage(showOptions: !usage.isEmpty, taskName: taskName, extendedArgsUsage: task.getExtendedArgsUsage());
  print(_indent(task.description));
  print('');

  if(!usage.isEmpty) {
    print('Task options:');
    print(_indent(task.getUsage()));
    print('');
  }

  _printHopArgsHelp(config);
}

void _helpParserConfig(BaseConfig config, ArgParser parser) {
  config.requireFrozen();

  for(final taskName in config.taskNames) {
    parser.addCommand(taskName);
  }
}

void _printHelp(BaseConfig config) {
  config.requireFrozen();
  _printUsage();
  print('Tasks:');
  _printTaskTable(config);

  print('');
  _printHopArgsHelp(config);

  print("See '$_hopCmdName <task>' for more information on a specific command.");
}

void _printUsage({bool showOptions: true, String taskName: '<task>', String extendedArgsUsage: '[--] [<task-args>]'}) {
  final taskOptions = showOptions ? '[<task-options>] ' : '';

  print('usage: $_hopCmdName [<hop-options>] $taskName $taskOptions$extendedArgsUsage'.trim());
  print('');
}

void _printHopArgsHelp(BaseConfig config) {
  final parser = _getParser(config);

  print('Hop options:');
  print(_indent(parser.getUsage()));
  print('');
}

String _indent(String input) {
  return Util.splitLines(input)
      .map((String line) => '  '.concat(line))
      .join(('\n'));
}

void _printTaskTable(BaseConfig config) {
  config.requireFrozen();
  final columns = [
                   new ColumnDefinition('name', (name) => '  '.concat(name)),
                   new ColumnDefinition('description', (name) {
                     final task = config._getTask(name);
                     return task.description;
                   })
                   ];
  final rows = Console.getTable(config.taskNames, columns);
  for(final r in rows) {
    print('  '.concat(r));
  }
}
