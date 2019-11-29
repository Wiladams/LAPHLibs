package.path = package.path..";../?.lua";

local SplayTree = require("splaytree")



local st = SplayTree();
local root = nil

local function initTree(st)
    local  vector = {9,8,7,6,5,4,3,2,1,0};
    local length = #vector

    for i = 1, length do
        root = st:insert(vector[i], root);
    end
end

--[[
    Braindead simple Iterator
    This should turn into a real functional iterator
]]
local function inOrder(root)
    if root then
        inOrder(root.lchild)
        io.write("key: ", root.key)
        if root.lchild then
            io.write(" | left child: ", root.lchild.key)
        end
        if root.rchild then
            io.write(" | right child: ", root.rchild.key)
        end
        print()

        inOrder(root.rchild)
    end
end

local function test_inorder(root)
    io.write("\nInOrder: \n");
    inOrder(root);
end

local function test_input()

    local input, choice;

    while true do
        io.write("\nSplay Tree Operations\n");
        print("1. Insert ");
        print("2. Delete");
        print("3. Search");
        print("4. Exit");
        io.write("Enter your choice: ");
        choice = tonumber(io.read())

        print(type(choice), choice)

        if choice == 1 then
            io.write("Enter value to be inserted: ");
            input = tonumber(io.read());
            root = st:insert(input, root);
            io.write("\nAfter Insert: ", input,'\n');
            st:inOrder(root);

        elseif choice == 2 then
            io.write("Enter value to be deleted: ");
            input = tonumber(io.read());
            root = st:delete(input, root);
            io.write("\nAfter Delete: ", input, '\n');
            st:inOrder(root);

        elseif choice == 3 then
            io.write("Enter value to be searched: ");
            input = tonumber(io.read());
            root = st:search(input, root);
            io.write("\nAfter Search ", input, '\n');
            st:inOrder(root);

        elseif choice == 4 then
            return 1;
        else
            io.write("\nInvalid type! \n");
        end

    end

    print()
end

initTree(st)
test_inorder(root)
--test_input()




